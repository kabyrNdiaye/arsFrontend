import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/mission_model.dart';
import '../../providers/mission_provider.dart';
import '../../utils/font_helper.dart';
import 'admin_mission_chat_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({Key? key}) : super(key: key);

  @override
  _AdminChatListScreenState createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";

  final Color _adminPurple = const Color(0xFF7C39D3);

  @override
  void initState() {
    super.initState();
    _loadMissions();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    Provider.of<MissionProvider>(context, listen: false).fetchMissions();
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);
    final missions = missionProvider.missions;

    // Group missions by structureId (fallback to structureName if ID is null)
    final Map<String, List<MissionModel>> groupedMissions = {};
    for (var m in missions) {
      final String groupKey = m.structureId?.toString() ?? m.structureName ?? 'Unknown';
      if (!groupedMissions.containsKey(groupKey)) {
        groupedMissions[groupKey] = [];
      }
      groupedMissions[groupKey]!.add(m);
    }

    // Convert to a list of "Conversations" (one per structure)
    List<StructureConversation> conversations = groupedMissions.entries.map((entry) {
      return StructureConversation(missions: entry.value);
    }).toList();

    // Sort by latest message date (most recent first)
    conversations.sort((a, b) => b.latestDate.compareTo(a.latestDate));

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      conversations = conversations.where((c) {
        return c.structureName.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _adminPurple,
        statusBarIconBrightness: Brightness.light, // Android icons
        statusBarBrightness: Brightness.dark,      // iOS text color (white)
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: _adminPurple,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          backgroundColor: _adminPurple,
          elevation: 0,
          toolbarHeight: 85.h,
          leading: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
            onPressed: () {
              if (_isSearching) {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Rechercher une structure...",
                    hintStyle: getInterStyle(fontSize: 14.sp, color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: getInterStyle(fontSize: 15.sp, color: Colors.white),
                )
              : Text(
                  "Messages des Structures",
                  style: getSourceSerifProStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchController.clear();
                  }
                  _isSearching = !_isSearching;
                });
              },
            ),
          ),
        ],
      ),
      body: missionProvider.isLoading && missionProvider.missions.isEmpty
          ? Center(child: CircularProgressIndicator(color: _adminPurple))
          : conversations.isEmpty
              ? _buildEmptyState(isFiltering: _searchQuery.isNotEmpty)
              : _buildConversationList(conversations),
    );
  }

  Widget _buildEmptyState({bool isFiltering = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltering ? Icons.search_off : Icons.chat_bubble_outline,
            size: 80.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            isFiltering ? "Aucun résultat trouvé" : "Aucune conversation",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            isFiltering
                ? "Essayez avec d'autres termes de recherche."
                : "Les messages des structures apparaîtront ici.",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(List<StructureConversation> conversations) {
    // Log pour debug
    for (final c in conversations) {
      debugPrint('Conversation ${c.structureName}: unread=${c.totalUnreadCount} missions=${c.missions.map((m) => "${m.id}:${m.unreadMessagesCount}").toList()}');
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: conversations.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _buildConversationTile(conversations[index]);
      },
    );
  }

  Widget _buildConversationTile(StructureConversation conversation) {
    final hasUnread = conversation.totalUnreadCount > 0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminMissionChatScreen(missions: conversation.missions),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          // Fond légèrement coloré si messages non lus
          color: hasUnread ? _adminPurple.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: hasUnread
              ? Border.all(color: _adminPurple.withOpacity(0.2), width: 1.5)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar avec badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: hasUnread
                        ? _adminPurple.withOpacity(0.15)
                        : _adminPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.business, color: _adminPurple, size: 24.sp),
                ),
                if (hasUnread)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                      child: Center(
                        child: Text(
                          conversation.totalUnreadCount > 9
                              ? '9+'
                              : conversation.totalUnreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.structureName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.bold,
                            color: hasUnread ? _adminPurple : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(conversation.latestDate),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: hasUnread ? _adminPurple : Colors.grey[400],
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (hasUnread) ...[
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Expanded(
                        child: Text(
                          conversation.latestMessageContent,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: hasUnread ? Colors.black87 : Colors.grey[600],
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios,
                color: hasUnread ? _adminPurple : Colors.grey[300],
                size: 14.sp),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('dd MMM').format(date);
  }
}

class StructureConversation {
  final List<MissionModel> missions;

  StructureConversation({required this.missions});

  String get structureName => missions.first.structureName ?? "Structure";

  int get totalUnreadCount => missions.fold(0, (sum, m) => sum + m.unreadMessagesCount);

  DateTime get latestDate {
    DateTime latest = missions.first.createdAt;
    for (var m in missions) {
      if (m.lastMessage != null && m.lastMessage!['created_at'] != null) {
        final msgDate = DateTime.tryParse(m.lastMessage!['created_at'].toString()) ?? m.createdAt;
        if (msgDate.isAfter(latest)) latest = msgDate;
      } else if (m.createdAt.isAfter(latest)) {
        latest = m.createdAt;
      }
    }
    return latest;
  }

  String get latestMessageContent {
    MissionModel? latestMission;
    DateTime? latestTime;

    for (var m in missions) {
      if (m.lastMessage != null) {
        final msgTime = DateTime.tryParse(m.lastMessage!['created_at']?.toString() ?? '') ?? m.createdAt;
        if (latestTime == null || msgTime.isAfter(latestTime)) {
          latestTime = msgTime;
          latestMission = m;
        }
      }
    }

    if (latestMission != null && latestMission.lastMessage != null) {
      return latestMission.lastMessage!['content'] ?? "Fichier joint";
    }
    return "Aucun message";
  }
}

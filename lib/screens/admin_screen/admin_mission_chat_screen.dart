import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/mission_model.dart';
import '../../providers/mission_provider.dart';
import '../../services/mission_service.dart';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../providers/language_provider.dart';
import '../shared/file_preview_screen.dart';

class AdminMissionChatScreen extends StatefulWidget {
  final MissionModel? mission;
  final List<MissionModel>? missions;

  const AdminMissionChatScreen({
    Key? key, 
    this.mission,
    this.missions,
  }) : super(key: key);

  @override
  _AdminMissionChatScreenState createState() => _AdminMissionChatScreenState();
}

 class _AdminMissionChatScreenState extends State<AdminMissionChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MissionService _missionService = MissionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _messages = [];
  
  final Color _adminPurple = const Color(0xFF7C39D3);
  final Color _structureBlue = const Color(0xFF3366E3);

  List<MissionModel> get _allMissions {
    if (widget.missions != null) return widget.missions!;
    if (widget.mission != null) return [widget.mission!];
    return [];
  }

  MissionModel? get _latestMission {
    if (_allMissions.isEmpty) return null;
    MissionModel latest = _allMissions.first;
    DateTime? latestTime;
    for (var m in _allMissions) {
      final msgTime = m.lastMessage != null 
          ? DateTime.tryParse(m.lastMessage!['created_at']?.toString() ?? '') 
          : m.createdAt;
      if (latestTime == null || (msgTime != null && msgTime.isAfter(latestTime))) {
        latestTime = msgTime;
        latest = m;
      }
    }
    return latest;
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markAllAsRead();
  }

  Future<void> _markAllAsRead() async {
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    for (var m in _allMissions) {
      _missionService.markChatAsRead(m.id);
      missionProvider.markMissionAsReadLocal(m.id);
      notifProvider.markAsReadByMissionId(m.id);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_allMissions.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> allMessages = [];
      
      // Load messages for all missions in the bundle
      await Future.wait(_allMissions.map((m) async {
        try {
          final msgs = await _missionService.getChatMessages(m.id);
          for (var msg in msgs) {
            // Add mission context if helpful
            msg['_mission_id'] = m.id;
            allMessages.add(msg);
          }
        } catch (e) {
          debugPrint('Error loading messages for mission ${m.id}: $e');
        }
      }));

      // Filter and Sort by date
      allMessages = allMessages.where((msg) => msg['type'] != 'incident' && msg['type'] != 'feedback').toList();
      allMessages.sort((a, b) {
        final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
        final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
        return aTime.compareTo(bTime);
      });

      setState(() {
        _messages = allMessages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des messages : $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final targetMission = _latestMission;
    if (targetMission == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      await _missionService.sendChatMessage(targetMission.id, content, type: 'text');
      if (mounted) {
        Provider.of<MissionProvider>(context, listen: false).markMissionAsReadLocal(targetMission.id);
      }
      _loadMessages(); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l’envoi : $e')),
        );
      }
    }
  }


  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e\nURL: $url')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final String title = _allMissions.isNotEmpty 
        ? (_allMissions.first.structureName ?? 'Mission') 
        : 'Chat';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 85.h,
        leading: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: _adminPurple, size: 20.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Structure: $title",
                style: getSourceSerifProStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _adminPurple,
                ),
              ),
              if (_allMissions.length > 1)
                Text(
                  "Conversation centralisée (${_allMissions.length} missions)",
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.grey[600]),
              onPressed: _loadMessages,
            ),
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: _adminPurple))
        : Column(
            children: [
              Expanded(
                child: _messages.isEmpty 
                  ? Center(child: Text("Aucun message", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.w),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final DateTime currentMsgDate = msg['created_at'] != null ? DateTime.parse(msg['created_at']) : DateTime.now();
                        
                        bool showDateHeader = false;
                        if (index == 0) {
                          showDateHeader = true;
                        } else {
                          final prevMessage = _messages[index - 1];
                          final DateTime prevMsgDate = prevMessage['created_at'] != null ? DateTime.parse(prevMessage['created_at']) : DateTime.now();
                          if (currentMsgDate.year != prevMsgDate.year || 
                              currentMsgDate.month != prevMsgDate.month || 
                              currentMsgDate.day != prevMsgDate.day) {
                            showDateHeader = true;
                          }
                        }

                        return Column(
                          children: [
                            if (showDateHeader) _buildDateSeparator(currentMsgDate, lang),
                            _buildChatBubble(msg),
                          ],
                        );
                      },
                    ),
              ),
              _buildMessageInput(),
            ],
          ),
    );
  }

  Widget _buildDateSeparator(DateTime date, LanguageProvider lang) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (checkDate == today) {
      dateText = lang.translate('today');
    } else if (checkDate == yesterday) {
      dateText = lang.translate('yesterday');
    } else {
      try {
        dateText = DateFormat('d MMMM yyyy', lang.currentLanguage).format(date);
      } catch (e) {
        dateText = DateFormat('d MMMM yyyy').format(date);
      }
    }

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE1E8ED),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          dateText,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF657786),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final userData = msg['user'] as Map<String, dynamic>?;
    final bool isMe = userData?['role'] == 'admin';
    final String senderName = userData?['name'] ?? 'Inconnu';
    final DateTime time = msg['created_at'] != null ? DateTime.parse(msg['created_at']) : DateTime.now();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isMe ? _adminPurple : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  senderName,
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: _structureBlue),
                ),
              ),

            if (msg['type'] == 'image' && msg['file_path'] != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilePreviewScreen(
                          fileUrl: msg['file_path'],
                          fileName: "Image",
                          fileType: 'image',
                          authToken: ApiService().token,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      msg['file_path'],
                      width: 200.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
            if (msg['type'] == 'file' && msg['file_path'] != null)
                GestureDetector(
                  onTap: () {
                    final String url = msg['file_path'];
                    final bool isPdf = url.toLowerCase().endsWith('.pdf');
                    
                    if (isPdf) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilePreviewScreen(
                            fileUrl: url,
                            fileName: msg['content'] ?? "Document",
                            fileType: 'pdf',
                            authToken: ApiService().token,
                          ),
                        ),
                      );
                    } else {
                      _launchURL(url);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.insert_drive_file, color: isMe ? Colors.white : _adminPurple),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          msg['content'] ?? 'Fichier',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            if (msg['content'] != null && (msg['type'] == 'text' || msg['type'] == null))
              Text(
                msg['content'] ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isMe ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(time),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: isMe ? Colors.white70 : Colors.grey[500],
                  ),
                ),
                if (msg['_mission_id'] != null && _allMissions.length > 1) ...[
                  SizedBox(width: 6.w),
                  Text(
                    "#${msg['_mission_id']}",
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: isMe ? Colors.white54 : Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 4.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Écrivez votre message...",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _adminPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

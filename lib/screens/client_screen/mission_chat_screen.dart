import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/language_provider.dart';
import '../../models/mission_model.dart';
import '../../providers/mission_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/font_helper.dart';
import '../../providers/notification_provider.dart';
import '../../services/mission_service.dart'; // Added this import
import '../../services/notification_service.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../shared/file_preview_screen.dart';

class MissionChatScreen extends StatefulWidget {
  final MissionModel mission;

  const MissionChatScreen({Key? key, required this.mission}) : super(key: key);

  @override
  _MissionChatScreenState createState() => _MissionChatScreenState();
}

class _MissionChatScreenState extends State<MissionChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Color _primaryGreen = const Color(0xFF4CA054);
  late LanguageProvider lang;
  final MissionService _missionService = MissionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _missionService.markChatAsRead(widget.mission.id);
    // Supprimer le badge localement immédiatement pour la réactivité
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
      
      missionProvider.markMissionAsReadLocal(widget.mission.id);
      notifProvider.markAsReadByMissionId(widget.mission.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _missionService.getChatMessages(widget.mission.id);
      setState(() {
        _messages = messages.where((msg) => msg['type'] != 'incident' && msg['type'] != 'feedback').toList();
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${lang.translate('error_loading_messages')} : $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      await _missionService.sendChatMessage(widget.mission.id, content, type: 'text');
      if (mounted) {
        Provider.of<MissionProvider>(context, listen: false).markMissionAsReadLocal(widget.mission.id);
      }
      _loadMessages(); // Reload to get the new message
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${lang.translate('error_sending')} : $e')),
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
          SnackBar(
            content: Text('${lang.translate('error')} : $e\nURL: $url'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    lang = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        toolbarHeight: 85.h,
        leading: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20.sp),
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
              Navigator.pop(context);
            },
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.translate('mission_chat'),
                style: getSourceSerifProStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                widget.mission.structureName ?? lang.translate('mission_details_hint'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: IconButton(
              icon: Icon(Icons.info_outline, color: _primaryGreen),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
          ? Center(child: CircularProgressIndicator(color: _primaryGreen))
          : Container(
              color: const Color(0xFFF9FAFB),
              child: _messages.isEmpty
                ? Center(child: Text(lang.translate('no_message'), style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final DateTime currentMsgDate = message['created_at'] != null ? DateTime.parse(message['created_at']) : DateTime.now();
                      
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
                          if (showDateHeader) _buildDateSeparator(currentMsgDate),
                          _buildChatBubble(message),
                        ],
                      );
                    },
                  ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }



  Widget _buildDateSeparator(DateTime date) {
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
      // Pour les autres dates, on utilise le format standard
      // On s'assure d'avoir le bon locale pour DateFormat
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

  Widget _buildChatBubble(Map<String, dynamic> message) {
    // Sur le client, on regarde si le rôle de l'expéditeur est 'client' (ou 'structure' selon l'API)
    final userData = message['user'] as Map<String, dynamic>?;
    final String role = (userData?['role'] ?? '').toString().toLowerCase();
    
    // Le message m'appartient si c'est un client (ou structure)
    final bool isMe = role == 'client' || role == 'structure';
    final String senderName = userData?['name'] ?? 'Admin';
    final DateTime time = message['created_at'] != null ? DateTime.parse(message['created_at']) : DateTime.now();
    final Color adminPurple = const Color(0xFF7C39D3);
    
    final bool isIncident = message['type'] == 'incident';
    final bool isFeedback = message['type'] == 'feedback';

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16.w,
              backgroundColor: adminPurple.withOpacity(0.1),
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : "A",
                style: TextStyle(color: adminPurple, fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isIncident 
                    ? Colors.red[50] 
                    : isFeedback 
                        ? Colors.amber[50] 
                        : isMe ? _primaryGreen : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                border: isIncident 
                    ? Border.all(color: Colors.red[300]!, width: 1.5)
                    : isFeedback 
                        ? Border.all(color: Colors.amber[400]!, width: 1.5)
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: adminPurple,
                        ),
                      ),
                    ),
                  
                  if (isIncident || isFeedback)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isIncident ? Icons.warning_amber_rounded : Icons.star_rounded,
                            color: isIncident ? Colors.red : Colors.amber[800],
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            isIncident ? lang.translate('incident_report_upper') : 'RETOUR',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: isIncident ? Colors.red : Colors.amber[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (message['type'] == 'image' && message['file_path'] != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilePreviewScreen(
                              fileUrl: message['file_path'],
                              fileName: "Image",
                              fileType: 'image',
                              authToken: ApiService().token,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message['file_path'],
                            width: 200.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  if (message['type'] == 'file' && message['file_path'] != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: GestureDetector(
                        onTap: () {
                          final String url = message['file_path'];
                          final bool isPdf = url.toLowerCase().endsWith('.pdf');
                          
                          if (isPdf) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilePreviewScreen(
                                  fileUrl: url,
                                  fileName: message['content'] ?? "Document",
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
                            Icon(Icons.insert_drive_file, color: isMe ? Colors.white : _primaryGreen),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                message['content'] ?? lang.translate('file_label') ?? 'Fichier',
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (message['type'] == 'audio' && message['file_path'] != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.sp),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.play_circle_fill, color: isMe ? Colors.white : _primaryGreen, size: 32.sp),
                            onPressed: () async {
                              await _audioPlayer.play(UrlSource(message['file_path']));
                            },
                          ),
                          Text(
                            lang.translate('voice_message'),
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  if (message['type'] == 'location' && message['latitude'] != null)
                    GestureDetector(
                      onTap: () async {
                        final url = 'https://www.google.com/maps/search/?api=1&query=${message['latitude']},${message['longitude']}';
                        _launchURL(url);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: isMe ? Colors.white : Colors.red),
                                  SizedBox(width: 8.w),
                                  Text(
                                    lang.translate('shared_location'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isMe ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                lang.translate('click_to_view_map'),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: isMe ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (message['content'] != null && (message['type'] == 'text' || message['type'] == null || isIncident || isFeedback))
                    Text(
                      message['content'] ?? '',
                      style: TextStyle(
                        color: (isIncident || isFeedback) ? Colors.black87 : (isMe ? Colors.white : Colors.black87),
                        fontSize: 14.sp,
                        fontWeight: (isIncident || isFeedback) ? FontWeight.w600 : FontWeight.normal,
                        height: 1.4,
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('HH:mm').format(time),
                    style: TextStyle(
                      color: (isIncident || isFeedback) ? Colors.grey[600] : (isMe ? Colors.white.withOpacity(0.8) : Colors.grey[400]),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, MediaQuery.of(context).padding.bottom + 12.h),
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
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: lang.translate('write_message'),
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}

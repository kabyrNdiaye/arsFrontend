class MessageModel {
  final int id;
  final int missionId;
  final String content;
  final DateTime createdAt;
  final int userId;
  final String userName;
  final String userRole;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.missionId,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      missionId: json['mission_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user']['id'],
      userName: json['user']['name'],
      userRole: json['user']['role'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mission_id': missionId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'user': {
        'id': userId,
        'name': userName,
        'role': userRole,
      },
    };
  }
}

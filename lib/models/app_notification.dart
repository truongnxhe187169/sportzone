/// Model thông báo trong app (đặt tên AppNotification để tránh conflict với dart:ui)
class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String type; // 'booking' | 'cancel' | 'reminder' | 'system'
  final bool isRead;
  final String createdAt; // ISO 8601

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] as int,
        userId: map['user_id'] as int,
        title: map['title'] as String,
        body: map['body'] as String,
        type: map['type'] as String,
        isRead: (map['is_read'] as int) == 1,
        createdAt: map['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': isRead ? 1 : 0,
        'created_at': createdAt,
      };

  AppNotification copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    String? createdAt,
  }) =>
      AppNotification(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        body: body ?? this.body,
        type: type ?? this.type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );
}

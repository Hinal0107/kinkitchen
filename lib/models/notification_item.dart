class NotificationItem {
  final int id;
  final int userId;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      isRead: (json['is_read'] is int)
          ? (json['is_read'] as int) == 1
          : (json['is_read'] as bool? ?? false),
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt,
    };
  }
}

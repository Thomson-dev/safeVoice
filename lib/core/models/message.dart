class Message {
  final String id;
  final String trackingCode;
  final String senderRole; // 'student' or 'counselor'
  final String content;
  final DateTime sentAt;
  final bool isRead;

  Message({
    required this.id,
    required this.trackingCode,
    required this.senderRole,
    required this.content,
    required this.sentAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingCode': trackingCode,
      'senderRole': senderRole,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      trackingCode: json['trackingCode'],
      senderRole: json['senderRole'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}

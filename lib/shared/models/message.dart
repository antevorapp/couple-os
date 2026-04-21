class Message {
  final String id;
  final String senderId;
  final String coupleId;
  final String content;
  final bool isAiComment;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.coupleId,
    required this.content,
    this.isAiComment = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      coupleId: json['couple_id'] as String,
      content: json['content'] as String,
      isAiComment: json['is_ai_comment'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'couple_id': coupleId,
        'content': content,
        'is_ai_comment': isAiComment,
        'created_at': createdAt.toIso8601String(),
      };
}

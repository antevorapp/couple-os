class LoveScore {
  final String id;
  final String userId;
  final String coupleId;
  final int score;
  final String? note;
  final DateTime createdAt;

  const LoveScore({
    required this.id,
    required this.userId,
    required this.coupleId,
    required this.score,
    this.note,
    required this.createdAt,
  });

  factory LoveScore.fromJson(Map<String, dynamic> json) {
    return LoveScore(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      coupleId: json['couple_id'] as String,
      score: json['score'] as int,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'couple_id': coupleId,
        'score': score,
        'note': note,
        'created_at': createdAt.toIso8601String(),
      };
}

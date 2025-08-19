class Match {
  final int? id;
  final int userId;
  final int matchedUserId;
  final int matchScore;
  final bool isLiked;
  final bool isMatched;
  final DateTime createdAt;

  Match({
    this.id,
    required this.userId,
    required this.matchedUserId,
    required this.matchScore,
    this.isLiked = false,
    this.isMatched = false,
    required this.createdAt,
  });

  // Convert Match object to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'matched_user_id': matchedUserId,
      'match_score': matchScore,
      'is_liked': isLiked ? 1 : 0,
      'is_matched': isMatched ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create a Match object from a Map from SQLite
  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'],
      userId: map['user_id'],
      matchedUserId: map['matched_user_id'],
      matchScore: map['match_score'],
      isLiked: map['is_liked'] == 1,
      isMatched: map['is_matched'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  // Create a copy of the Match with updated fields
  Match copyWith({
    int? id,
    int? userId,
    int? matchedUserId,
    int? matchScore,
    bool? isLiked,
    bool? isMatched,
    DateTime? createdAt,
  }) {
    return Match(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      matchedUserId: matchedUserId ?? this.matchedUserId,
      matchScore: matchScore ?? this.matchScore,
      isLiked: isLiked ?? this.isLiked,
      isMatched: isMatched ?? this.isMatched,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.entityType,
    required this.entityId,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.comment,
  });

  final String id;
  final String userId;
  final String userName;
  final String entityType;
  final String entityId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Petly user',
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}

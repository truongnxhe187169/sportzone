/// Model đánh giá sân thể thao
class Review {
  final int id;
  final int courtId;
  final int userId;
  final double rating;
  final String? comment;
  final String createdAt; // ISO 8601
  final String? userName; // từ JOIN với users

  const Review({
    required this.id,
    required this.courtId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
  });

  factory Review.fromMap(Map<String, dynamic> map) => Review(
        id: map['id'] as int,
        courtId: map['court_id'] as int,
        userId: map['user_id'] as int,
        rating: (map['rating'] as num).toDouble(),
        comment: map['comment'] as String?,
        createdAt: map['created_at'] as String,
        userName: map['user_name'] as String?,
      );
}

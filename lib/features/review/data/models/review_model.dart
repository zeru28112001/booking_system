import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.providerId,
    required super.authorName,
    required super.rating,
    required super.comment,
    required super.date,
    super.bookingId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] ?? '').toString(),
      providerId: (json['provider_id'] as String?) ??
          (json['providerId'] as String?) ??
          '',
      bookingId: (json['booking_id'] as String?) ??
          (json['bookingId'] as String?),
      authorName: (json['author_name'] as String?) ??
          (json['authorName'] as String?) ??
          'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: (json['comment'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'booking_id': bookingId,
      'author_name': authorName,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }
}

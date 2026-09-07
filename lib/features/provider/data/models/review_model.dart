import '../../domain/entities/review.dart';

/// Data-layer DTO — extends Review and adds JSON (de)serialization.
/// Screens and providers never import this class.
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.authorName,
    required super.rating,
    required super.comment,
    required super.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] ?? '').toString(),
      authorName: (json['author_name'] as String?) ??
          (json['authorName'] as String?) ??
          '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: (json['comment'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_name': authorName,
        'rating': rating,
        'comment': comment,
        'date': date,
      };
}

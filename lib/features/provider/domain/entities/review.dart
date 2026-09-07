/// Domain entity — one customer review of a ServiceProvider.
/// No JSON logic here. No HTTP imports.
class Review {
  const Review({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String id;
  final String authorName;

  /// 1–5 stars.
  final int rating;
  final String comment;

  /// 'yyyy-MM-dd'.
  final String date;

  @override
  String toString() => 'Review(id: $id, author: $authorName, rating: $rating)';
}

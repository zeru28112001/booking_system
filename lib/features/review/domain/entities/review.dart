/// Domain entity — a user review and rating for a provider.
/// No JSON logic here. No HTTP imports.
class Review {
  const Review({
    required this.id,
    required this.providerId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
    this.bookingId,
  });

  final String id;
  final String providerId;
  final String? bookingId;
  final String authorName;
  final double rating; // 1.0 to 5.0
  final String comment;
  final String date; // 'yyyy-MM-dd'

  @override
  String toString() => 'Review(id: $id, rating: $rating, author: $authorName)';
}

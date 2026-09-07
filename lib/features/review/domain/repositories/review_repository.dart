import '../entities/review.dart';

/// Contract for fetching and submitting provider reviews.
abstract class ReviewRepository {
  Future<List<Review>> getProviderReviews(String providerId);

  Future<Review> submitReview({
    required String providerId,
    required double rating,
    required String comment,
    String? bookingId,
    String? authorName,
  });
}

import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../services/review_api_service.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl({
    required this.reviewApiService,
  });

  final ReviewApiService reviewApiService;

  @override
  Future<List<Review>> getProviderReviews(String providerId) async {
    return reviewApiService.getProviderReviews(providerId);
  }

  @override
  Future<Review> submitReview({
    required String providerId,
    required double rating,
    required String comment,
    String? bookingId,
    String? authorName,
  }) async {
    return reviewApiService.submitReview(
      providerId: providerId,
      rating: rating,
      comment: comment,
      bookingId: bookingId,
      authorName: authorName,
    );
  }
}


import '../../../../core/network/api_client.dart';
import '../models/review_model.dart';

class ReviewApiService {
  const ReviewApiService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<ReviewModel>> getProviderReviews(String providerId) async {
    final data = await apiClient.get('/providers/$providerId/reviews');
    final list = data is Map<String, dynamic>
        ? (data['data'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);
    return list
        .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewModel> submitReview({
    required String providerId,
    required double rating,
    required String comment,
    String? bookingId,
    String? authorName,
  }) async {
    final data = await apiClient.post(
      '/providers/$providerId/reviews',
      body: {
        'provider_id': providerId,
        'rating': rating,
        'comment': comment,
        'booking_id':? bookingId,
        'author_name':? authorName,
      },
    );
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ReviewModel.fromJson(map);
  }
}

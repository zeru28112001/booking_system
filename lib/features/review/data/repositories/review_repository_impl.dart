import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';
import '../services/review_api_service.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl({
    required this.reviewApiService,
    this.useMock = true,
  });

  final ReviewApiService reviewApiService;
  final bool useMock;

  static const _prefKeyUserReviews = 'user_submitted_reviews';

  @override
  Future<List<Review>> getProviderReviews(String providerId) async {
    if (!useMock) return reviewApiService.getProviderReviews(providerId);

    await Future.delayed(const Duration(milliseconds: 400));
    final userReviews = await _readUserReviews();
    return userReviews.where((r) => r.providerId == providerId).toList();
  }

  @override
  Future<Review> submitReview({
    required String providerId,
    required double rating,
    required String comment,
    String? bookingId,
    String? authorName,
  }) async {
    if (!useMock) {
      return reviewApiService.submitReview(
        providerId: providerId,
        rating: rating,
        comment: comment,
        bookingId: bookingId,
        authorName: authorName,
      );
    }

    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    final review = ReviewModel(
      id: 'rev_${now.millisecondsSinceEpoch}',
      providerId: providerId,
      bookingId: bookingId,
      authorName: authorName ?? 'You',
      rating: rating,
      comment: comment,
      date: AppFormatters.isoDay(now),
    );

    final stored = await _readUserReviews();
    stored.insert(0, review);
    await _writeUserReviews(stored);
    return review;
  }

  Future<List<ReviewModel>> _readUserReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyUserReviews);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeUserReviews(List<ReviewModel> reviews) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKeyUserReviews,
      jsonEncode(reviews.map((r) => r.toJson()).toList()),
    );
  }
}

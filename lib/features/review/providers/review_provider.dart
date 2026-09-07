import 'package:flutter/foundation.dart';
import '../domain/entities/review.dart';
import '../domain/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({required this.reviewRepository});

  final ReviewRepository reviewRepository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  List<Review> _reviews = [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  List<Review> get reviews => _reviews;

  Future<void> fetchProviderReviews(String providerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reviews = await reviewRepository.getProviderReviews(providerId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Review?> submitReview({
    required String providerId,
    required double rating,
    required String comment,
    String? bookingId,
    String? authorName,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final review = await reviewRepository.submitReview(
        providerId: providerId,
        rating: rating,
        comment: comment,
        bookingId: bookingId,
        authorName: authorName,
      );
      _reviews.insert(0, review);
      return review;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required this.profileRepository});

  final ProfileRepository profileRepository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  UserProfile? _profile;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  UserProfile? get profile => _profile;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await profileRepository.getProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String address,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await profileRepository.updateProfile(
        name: name,
        email: email,
        address: address,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferences({
    String? language,
    bool? notificationsEnabled,
  }) async {
    try {
      _profile = await profileRepository.updatePreferences(
        language: language,
        notificationsEnabled: notificationsEnabled,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

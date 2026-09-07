import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';
import '../services/profile_api_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required this.profileApiService,
    this.useMock = true,
  });

  final ProfileApiService profileApiService;
  final bool useMock;

  static const _prefKeyProfile = 'stored_user_profile';

  @override
  Future<UserProfile> getProfile() async {
    if (!useMock) return profileApiService.getProfile();

    await Future.delayed(const Duration(milliseconds: 300));
    return _readStoredProfile();
  }

  @override
  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    required String address,
  }) async {
    if (!useMock) {
      return profileApiService.updateProfile(
        name: name,
        email: email,
        address: address,
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));
    final current = await _readStoredProfile();
    final updated = ProfileModel(
      id: current.id,
      name: name,
      phone: current.phone,
      email: email,
      address: address,
      avatarUrl: current.avatarUrl,
      language: current.language,
      notificationsEnabled: current.notificationsEnabled,
    );
    await _writeStoredProfile(updated);
    return updated;
  }

  @override
  Future<UserProfile> updatePreferences({
    String? language,
    bool? notificationsEnabled,
  }) async {
    final current = await _readStoredProfile();
    final updated = ProfileModel(
      id: current.id,
      name: current.name,
      phone: current.phone,
      email: current.email,
      address: current.address,
      avatarUrl: current.avatarUrl,
      language: language ?? current.language,
      notificationsEnabled:
          notificationsEnabled ?? current.notificationsEnabled,
    );
    await _writeStoredProfile(updated);
    return updated;
  }

  Future<ProfileModel> _readStoredProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyProfile);
    if (raw == null) {
      const defaultProfile = ProfileModel(
        id: 'usr_001',
        name: 'Khin Su Su',
        phone: '09 987 654 321',
        email: 'khinsusu@gmail.com',
        address: 'No. 42, Kabar Aye Pagoda Rd, Mayangone',
        language: 'English',
        notificationsEnabled: true,
      );
      await _writeStoredProfile(defaultProfile);
      return defaultProfile;
    }
    try {
      return ProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      const fallback = ProfileModel(
        id: 'usr_001',
        name: 'Khin Su Su',
        phone: '09 987 654 321',
        email: 'khinsusu@gmail.com',
        address: 'No. 42, Kabar Aye Pagoda Rd, Mayangone',
      );
      return fallback;
    }
  }

  Future<void> _writeStoredProfile(ProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyProfile, jsonEncode(profile.toJson()));
  }
}

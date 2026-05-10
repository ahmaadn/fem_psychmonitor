import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/user_repository.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for Profile, Edit Profile, and Change Password screens.
class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepo;

  UserModel? _user;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _successMessage;

  ProfileViewModel({required UserRepository userRepo}) : _userRepo = userRepo;

  // ── Getters ────────────────────────────────────────────────────────────

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // ── Actions ────────────────────────────────────────────────────────────

  /// Load user profile data.
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userRepo.getProfile();
    } catch (e) {
      _error = 'Gagal memuat profil: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update user profile.
  Future<bool> updateProfile(UserModel updatedUser) async {
    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      _user = await _userRepo.updateProfile(updatedUser);
      _successMessage = 'Profil berhasil disimpan';
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menyimpan profil: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password.
  Future<bool> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _userRepo.changePassword(oldPassword, newPassword);
      _successMessage = 'Password berhasil diubah';
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengubah password: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear messages.
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}

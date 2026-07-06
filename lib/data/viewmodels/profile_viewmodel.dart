import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/user_repository.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
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
  ///
  /// [l10n] is optional so callers without a BuildContext can still load. When
  /// provided, the error message is localized (US-18).
  Future<void> loadProfile({AppLocalizations? l10n}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userRepo.getProfile();
    } catch (e) {
      final prefix = l10n?.profileLoadFailed ?? 'Failed to load profile';
      _error = '$prefix: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update user profile.
  ///
  /// [l10n] is required so success/error messages are localized at the
  /// presentation layer instead of hard-coded Indonesian (US-18).
  Future<bool> updateProfile(
    UserModel updatedUser,
    AppLocalizations l10n,
  ) async {
    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      _user = await _userRepo.updateProfile(updatedUser);
      _successMessage = l10n.profileSaveSuccess;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '${l10n.profileSaveFailed}: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password.
  ///
  /// [l10n] is required so success/error messages are localized (US-18).
  Future<bool> changePassword(
    String oldPassword,
    String newPassword,
    AppLocalizations l10n,
  ) async {
    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _userRepo.changePassword(oldPassword, newPassword);
      _successMessage = l10n.passwordChangeSuccess;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '${l10n.passwordChangeFailed}: $e';
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

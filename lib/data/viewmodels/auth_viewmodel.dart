import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

/// Manages authentication state across the app.
/// All screens observe this ViewModel for auth status.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;

  AuthState _state = AuthState.initial();

  AuthViewModel({required AuthRepository authRepo}) : _authRepo = authRepo;

  // ── Getters ────────────────────────────────────────────────────────────

  AuthState get state => _state;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isLoading => _state.isLoading;
  UserModel? get currentUser => _state.user;
  String? get error => _state.errorMessage;

  // ── Actions ────────────────────────────────────────────────────────────

  /// Login with email and password.
  Future<bool> login(String email, String password) async {
    _state = AuthState.loading();
    notifyListeners();

    _state = await _authRepo.login(email, password);
    notifyListeners();

    return _state.isAuthenticated;
  }

  /// Register a new user.
  Future<bool> register(
    String fullName,
    String email,
    String password,
  ) async {
    _state = AuthState.loading();
    notifyListeners();

    _state = await _authRepo.register(fullName, email, password);
    notifyListeners();

    return _state.isAuthenticated;
  }

  /// Log out and clear state.
  Future<void> logout() async {
    await _authRepo.logout();
    _state = AuthState.initial();
    notifyListeners();
  }

  /// Check if user is still authenticated (e.g., on app launch).
  Future<void> checkAuth() async {
    _state = await _authRepo.getCurrentAuth();
    notifyListeners();
  }

  /// Request password reset.
  Future<void> forgotPassword(String email) async {
    await _authRepo.forgotPassword(email);
  }

  /// Clear any error message.
  void clearError() {
    if (_state.errorMessage != null) {
      _state = _state.copyWith(
        errorMessage: null,
        status: _state.status,
      );
      notifyListeners();
    }
  }
}

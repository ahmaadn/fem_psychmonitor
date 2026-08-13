import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;

  AuthState _state = AuthState.initial();

  AuthViewModel({required AuthRepository authRepo}) : _authRepo = authRepo;

  AuthState get state => _state;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isLoading => _state.isLoading;
  UserModel? get currentUser => _state.user;
  bool get isGuest => _state.user?.isGuest ?? false;
  bool get hasCompletedAssessment =>
      _state.user?.hasCompletedAssessment ?? false;
  String? get error => _state.errorMessage;

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading();
    notifyListeners();
    _state = await _authRepo.login(email, password);
    notifyListeners();
    return _state.isAuthenticated;
  }

  Future<bool> register(String fullName, String email, String password) async {
    _state = AuthState.loading();
    notifyListeners();
    _state = await _authRepo.register(fullName, email, password);
    notifyListeners();
    return _state.isAuthenticated;
  }

  Future<bool> continueAsGuest() async {
    _state = AuthState.loading();
    notifyListeners();
    _state = await _authRepo.continueAsGuest();
    notifyListeners();
    return _state.isAuthenticated;
  }

  Future<void> logout() async {
    await _authRepo.logout();
    _state = AuthState.initial();
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _state = await _authRepo.getCurrentAuth();
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    await _authRepo.forgotPassword(email);
  }

  Future<void> refreshUser(UserModel user) async {
    if (!_state.isAuthenticated) return;
    _state = AuthState.authenticated(user: user, token: _state.token);
    notifyListeners();
  }

  Future<bool> saveAssessment(UserModel updated) async {
    final saved = await _authRepo.updateUserAssessment(updated);
    if (saved == null) return false;
    await refreshUser(saved);
    return true;
  }

  Future<void> deleteAccount() async {
    final id = currentUser?.id;
    if (id == null) return;
    await _authRepo.deleteAccount(id);
    _state = AuthState.initial();
    notifyListeners();
  }

  Future<void> resetData() async {
    final id = currentUser?.id;
    if (id == null) return;
    await _authRepo.resetUserData(id);
    await checkAuth();
  }

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

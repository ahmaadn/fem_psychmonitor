import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';

class DummyAuthRepository implements AuthRepository {
  AuthState _currentState = AuthState.initial();

  static final _dummyUser = UserModel(
    id: 'usr_001',
    fullName: 'Adinda Larasati',
    email: 'adinda.larasati@email.com',
    phone: '081234567890',
    dateOfBirth: DateTime(1998, 3, 15),
    createdAt: DateTime(2025, 1, 10),
  );

  @override
  Future<AuthState> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.isEmpty || password.isEmpty) {
      _currentState = AuthState.error('Email dan password harus diisi');
      return _currentState;
    }
    _currentState = AuthState.authenticated(
      user: _dummyUser.copyWith(email: email),
      token: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    return _currentState;
  }

  @override
  Future<AuthState> register(
    String fullName,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _currentState = AuthState.error('Semua field harus diisi');
      return _currentState;
    }
    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      createdAt: DateTime.now(),
    );
    _currentState = AuthState.authenticated(
      user: newUser,
      token: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    return _currentState;
  }

  @override
  Future<AuthState> continueAsGuest() async {
    final guest = UserModel(
      id: 'guest_local',
      fullName: 'Tamu',
      email: 'guest@local',
      createdAt: DateTime.now(),
      isGuest: true,
    );
    _currentState = AuthState.authenticated(user: guest, token: 'guest_token');
    return _currentState;
  }

  @override
  Future<void> logout() async {
    _currentState = AuthState.initial();
  }

  @override
  Future<AuthState> getCurrentAuth() async => _currentState;

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<UserModel?> updateUserAssessment(UserModel user) async {
    _currentState = AuthState.authenticated(
      user: user,
      token: _currentState.token,
    );
    return user;
  }

  @override
  Future<void> deleteAccount(String userId) async {
    _currentState = AuthState.initial();
  }

  @override
  Future<void> resetUserData(String userId) async {
    final u = _currentState.user;
    if (u == null) return;
    _currentState = AuthState.authenticated(
      user: u.copyWith(clearOcean: true, clearPsych: true),
      token: _currentState.token,
    );
  }
}

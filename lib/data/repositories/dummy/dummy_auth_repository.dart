import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';

/// Dummy implementation that always succeeds with in-memory state.
/// Replace with real API/SQLite implementation later.
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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || password.isEmpty) {
      _currentState = AuthState.error('Email dan password harus diisi');
      return _currentState;
    }

    // Always succeed with dummy user
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

    // Create new user from input
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
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentState = AuthState.initial();
  }

  @override
  Future<AuthState> getCurrentAuth() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentState;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Always succeed in dummy
  }
}

import 'package:fem_psychmonitor/data/models/auth_state.dart';

/// Contract for authentication operations.
/// Implementations: DummyAuthRepository, (future) ApiAuthRepository
abstract class AuthRepository {
  /// Attempt login with email and password.
  Future<AuthState> login(String email, String password);

  /// Register a new user.
  Future<AuthState> register(String fullName, String email, String password);

  /// Log out the current user.
  Future<void> logout();

  /// Check current authentication state (e.g., from stored token).
  Future<AuthState> getCurrentAuth();

  /// Request password reset email.
  Future<void> forgotPassword(String email);
}

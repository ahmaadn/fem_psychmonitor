import 'package:fem_psychmonitor/data/models/user_model.dart';

/// Contract for user profile operations.
/// Implementations: DummyUserRepository, (future) SqliteUserRepository, ApiUserRepository
abstract class UserRepository {
  /// Get the current user's profile.
  Future<UserModel> getProfile();

  /// Update user profile data.
  Future<UserModel> updateProfile(UserModel user);

  /// Change the user's password.
  Future<void> changePassword(String oldPassword, String newPassword);
}

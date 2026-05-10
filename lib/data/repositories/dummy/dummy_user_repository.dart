import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/user_repository.dart';

/// Dummy implementation that stores user data in memory.
/// Replace with real SQLite/API implementation later.
class DummyUserRepository implements UserRepository {
  UserModel _user = UserModel(
    id: 'usr_001',
    fullName: 'Adinda Larasati',
    email: 'adinda.larasati@email.com',
    phone: '081234567890',
    dateOfBirth: DateTime(1998, 3, 15),
    createdAt: DateTime(2025, 1, 10),
  );

  /// Allow updating the stored user from outside (e.g., after login/register).
  void setUser(UserModel user) {
    _user = user;
  }

  @override
  Future<UserModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _user;
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _user = user;
    return _user;
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Always succeed in dummy implementation
  }
}

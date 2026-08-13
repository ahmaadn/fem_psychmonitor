import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';

abstract class AuthRepository {
  Future<AuthState> login(String email, String password);
  Future<AuthState> register(String fullName, String email, String password);
  Future<AuthState> continueAsGuest();
  Future<void> logout();
  Future<AuthState> getCurrentAuth();
  Future<void> forgotPassword(String email);
  Future<UserModel?> updateUserAssessment(UserModel user);
  Future<void> deleteAccount(String userId);
  Future<void> resetUserData(String userId);
}

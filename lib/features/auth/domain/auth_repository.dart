import 'user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signIn({required String email, required String password});
  Future<UserEntity?> signUp({required String email, required String password});
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
}

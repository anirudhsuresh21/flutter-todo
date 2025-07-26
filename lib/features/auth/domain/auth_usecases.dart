import 'auth_repository.dart';
import 'user_entity.dart';

class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);
  Future<UserEntity?> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}

class SignUp {
  final AuthRepository repository;
  SignUp(this.repository);
  Future<UserEntity?> call({required String email, required String password}) {
    return repository.signUp(email: email, password: password);
  }
}

class SignInWithGoogle {
  final AuthRepository repository;
  SignInWithGoogle(this.repository);
  Future<UserEntity?> call() {
    return repository.signInWithGoogle();
  }
}

class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);
  Future<void> call() {
    return repository.signOut();
  }
}

class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);
  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}

import '../repository/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  /// Ejecuta el login y devuelve el token JWT
  Future<String> call(String email, String password) {
    return repository.login(email, password);
  }
}

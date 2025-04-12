abstract class AuthRepository {
  /// Inicia sesión y devuelve el token JWT
  Future<String> login(String email, String password);
}

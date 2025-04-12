abstract class AuthRemoteDataSource {
  /// Devuelve el token JWT si el login es exitoso
  Future<String> login(String email, String password);
}

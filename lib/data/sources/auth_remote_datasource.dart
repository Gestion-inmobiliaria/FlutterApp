import 'package:inmobiliaria_app/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  /// Devuelve el token JWT si el login es exitoso
  Future<String> login(String email, String password);
  Future<void> register(UserEntity user);
}

import 'package:inmobiliaria_app/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> register(UserEntity user); // 👈 nuevo método
  /// Inicia sesión y devuelve el token JWT
  Future<String> login(String email, String password);
}

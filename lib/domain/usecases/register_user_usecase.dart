import 'package:inmobiliaria_app/domain/entities/user_entity.dart';
import 'package:inmobiliaria_app/domain/repository/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<void> call(UserEntity user) async {
    return await repository.register(user);
  }
}

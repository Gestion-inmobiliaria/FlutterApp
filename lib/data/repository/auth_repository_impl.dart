import '../../domain/repository/auth_repository.dart';
import '../sources/auth_remote_datasource.dart';

// La clase `AuthRepositoryImpl` implementa la interfaz `AuthRepository`.
// Su objetivo es manejar la lógica de autenticación y delegar las operaciones
// específicas a la fuente de datos remota (`AuthRemoteDataSource`).

class AuthRepositoryImpl implements AuthRepository {
  // Dependencia de la fuente de datos remota.
  // `AuthRemoteDataSource` se utiliza para realizar las operaciones de autenticación
  // directamente con un servidor o API.
  final AuthRemoteDataSource remoteDataSource;

  // Constructor que recibe una instancia de `AuthRemoteDataSource`.
  // Esto permite inyectar la dependencia, facilitando pruebas y mantenimiento.
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  // Método para iniciar sesión.
  // Este método recibe un correo electrónico (`email`) y una contraseña (`password`),
  // y delega la operación de inicio de sesión a la fuente de datos remota.
  Future<String> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }
}

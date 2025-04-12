import 'package:http/http.dart' as http;

import 'data/sources/auth_remote_datasource_impl.dart';
import 'data/repository/auth_repository_impl.dart';
import 'domain/usecases/login_user.dart';

void main() async {
  final client = http.Client();

  // Crear instancia de datasource, repo y usecase
  final remoteDataSource = AuthRemoteDataSourceImpl(client: client);
  final repository = AuthRepositoryImpl(remoteDataSource);
  final loginUser = LoginUser(repository);

  try {
    final token = await loginUser('admin@correo.com', 'admin123');
    print('✅ Token obtenido:\n$token');
  } catch (e) {
    print('❌ Error durante login:\n$e');
  }
}

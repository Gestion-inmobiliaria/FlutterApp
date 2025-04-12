import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'domain/usecases/login_user.dart';
import 'data/repository/auth_repository_impl.dart';
import 'data/sources/auth_remote_datasource.dart';
import 'data/sources/auth_remote_datasource_impl.dart';
import 'domain/repository/auth_repository.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void setupLocator() {
  // External
  sl.registerLazySingleton(() => http.Client());

  // DataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // UseCase
  sl.registerLazySingleton(() => LoginUser(sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(sl()));
}

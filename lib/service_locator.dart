import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:inmobiliaria_app/domain/usecases/register_user_usecase.dart';
import 'package:inmobiliaria_app/presentation/visits/bloc/visitas_bloc.dart';
import 'domain/usecases/login_user.dart';
import 'data/repository/auth_repository_impl.dart';
import 'data/sources/auth_remote_datasource.dart';
import 'data/sources/auth_remote_datasource_impl.dart';
import 'domain/repository/auth_repository.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'package:inmobiliaria_app/data/sources/property_remote_datasource.dart';

// Favoritos
import 'package:inmobiliaria_app/data/sources/favorite_remote_datasource.dart';
import 'package:inmobiliaria_app/data/repository/favorite_repository_impl.dart';
import 'package:inmobiliaria_app/domain/repository/favorite_repository.dart';
import 'package:inmobiliaria_app/domain/usecases/favorite_usecases.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/favorite_bloc.dart';

final sl = GetIt.instance;

void setupLocator() {
  // External
  sl.registerLazySingleton(() => http.Client());

  // DataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSourceImpl(client: sl()),
  );

  // Datasources
  sl.registerLazySingleton<PropertyRemoteDatasource>(
    () => PropertyRemoteDatasource(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl())); // ✅ nuevo

  // Favorite UseCases
  sl.registerLazySingleton(() => AddToFavoritesUseCase(repository: sl()));
  sl.registerLazySingleton(() => RemoveFromFavoritesUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(repository: sl()));
  sl.registerLazySingleton(
    () => GetFavoritesByRealStateUseCase(repository: sl()),
  );
  sl.registerLazySingleton(() => CheckIsFavoriteUseCase(repository: sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(sl(), sl())); // ✅ actualizado
  sl.registerFactory(() => VisitBloc());
  sl.registerFactory(
    () => FavoriteBloc(
      addToFavoritesUseCase: sl(),
      removeFromFavoritesUseCase: sl(),
      getFavoritesUseCase: sl(),
      getFavoritesByRealStateUseCase: sl(),
      checkIsFavoriteUseCase: sl(),
    ),
  );
}

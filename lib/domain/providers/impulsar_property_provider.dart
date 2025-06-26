import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inmobiliaria_app/data/sources/impulsar_property_remote_datasource.dart';
import 'package:inmobiliaria_app/data/repository/impulso_property_repository_impl.dart';
import 'package:inmobiliaria_app/domain/entities/impulso_property.dart';
import 'package:http/http.dart' as http;

// Provider para el datasource
final impulsoDatasourceProvider = Provider<ImpulsoPropertyRemoteDatasource>((ref) {
  return ImpulsoPropertyRemoteDatasource();
});

// Provider para el repositorio
final impulsoRepositoryProvider = Provider<ImpulsoPropertyRepositoryImpl>((ref) {
  final datasource = ref.watch(impulsoDatasourceProvider);
  return ImpulsoPropertyRepositoryImpl(datasource);
});

// Provider para obtener todos los impulsos
final impulsoPropertiesProvider = FutureProvider<List<ImpulsoProperty>>((ref) {
  final repository = ref.watch(impulsoRepositoryProvider);
  return repository.getImpulsos();
});
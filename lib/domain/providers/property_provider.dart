import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inmobiliaria_app/data/repository/property_repository_impl.dart';
import 'package:inmobiliaria_app/data/sources/property_remote_datasource.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/domain/entities/user_entity.dart';

// Provider para el datasource
final propertyDatasourceProvider = Provider<PropertyRemoteDatasource>((ref) {
  return PropertyRemoteDatasource();
});

// Provider para el repositorio
final propertyRepositoryProvider = Provider<PropertyRepositoryImpl>((ref) {
  final datasource = ref.watch(propertyDatasourceProvider);
  return PropertyRepositoryImpl(datasource);
});

// Provider para obtener todas las propiedades
final propertiesProvider = FutureProvider<List<Property>>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return repository.getProperties();
});

// Provider para obtener una propiedad por ID
final propertyByIdProvider = FutureProvider.family<Property, String>((
  ref,
  propertyId,
) {
  final repository = ref.watch(propertyRepositoryProvider);
  return repository.getPropertyById(propertyId);
});

// Provider para obtener el agente de una propiedad
final propertyAgentProvider = FutureProvider.family<UserEntity, String>((
  ref,
  propertyId,
) {
  final repository = ref.watch(propertyRepositoryProvider);
  return repository.getPropertyAgent(propertyId);
});

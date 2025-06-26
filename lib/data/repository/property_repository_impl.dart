import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/domain/entities/user_entity.dart';
import 'package:inmobiliaria_app/domain/repository/property_repository.dart';
import 'package:inmobiliaria_app/data/sources/property_remote_datasource.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDatasource remoteDatasource;

  PropertyRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Property>> getProperties() {
    return remoteDatasource.fetchProperties();
  }

  @override
  Future<List<Property>> getPropertiesBySector(String sectorId) {
    return remoteDatasource.fetchPropertiesBySector(sectorId);
  }

  @override
  Future<List<Property>> getPropertiesByRealState(String realStateId) {
    return remoteDatasource.fetchPropertiesByRealState(realStateId);
  }

  @override
  Future<Property> getPropertyById(String propertyId) {
    return remoteDatasource.fetchPropertyById(propertyId);
  }

  @override
  Future<UserEntity> getPropertyAgent(String propertyId) {
    return remoteDatasource.fetchPropertyAgent(propertyId);
  }
} 
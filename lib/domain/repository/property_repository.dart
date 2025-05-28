import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/domain/entities/user_entity.dart';

abstract class PropertyRepository {
  Future<List<Property>> getProperties();
  Future<List<Property>> getPropertiesBySector(String sectorId);
  Future<List<Property>> getPropertiesByRealState(String realStateId);
  Future<Property> getPropertyById(String propertyId);
  Future<UserEntity> getPropertyAgent(String propertyId);
} 
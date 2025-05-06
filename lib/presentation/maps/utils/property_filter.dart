// utils/property_filter.dart
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';

class PropertyFilter {
  final double? minPrecio;
  final double? maxPrecio;
  final int? minHabitaciones;
  final int? minBanos;
  final String? categoria;
  final String? modalidad;

  PropertyFilter({
    this.minPrecio,
    this.maxPrecio,
    this.minHabitaciones,
    this.minBanos,
    this.categoria,
    this.modalidad,
  });

  bool apply(Property property) {
    if (minPrecio != null && property.precio < minPrecio!) return false;
    if (maxPrecio != null && property.precio > maxPrecio!) return false;
    if (minHabitaciones != null &&
        (property.nroHabitaciones ?? 0) < minHabitaciones!)
      return false;
    if (minBanos != null && (property.nroBanos ?? 0) < minBanos!) return false;
    if (categoria != null &&
        categoria!.isNotEmpty &&
        property.categoria?.toLowerCase() != categoria!.toLowerCase()) {
      return false;
    }
    if (modalidad != null &&
        modalidad!.isNotEmpty &&
        property.modalidad?.toLowerCase() != modalidad!.toLowerCase()) {
      return false;
    }

    return true;
  }
}

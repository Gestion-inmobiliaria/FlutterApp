import 'package:inmobiliaria_app/domain/entities/property_entity.dart';

class ImpulsoProperty{

 final DateTime startDate;
 final DateTime endDate;
 final String status;
 final String razonAImpulsar;
 final String? razonACancelar; 
 final DateTime? cancelled_at;
 final Property property;
 
 ImpulsoProperty({
  required this.startDate,
  required this.endDate,
  required this.status,
  required this.razonAImpulsar,
  this.razonACancelar,
  this.cancelled_at,
  required this.property,
 });

  factory ImpulsoProperty.fromJson(Map<String, dynamic> json) {
    return ImpulsoProperty(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      razonAImpulsar: json['razonAImpulsar'],
      razonACancelar: json['razonACancelar'],
      cancelled_at: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      property: Property.fromJson(json['property']),
    );
  }
}
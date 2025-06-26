import 'package:inmobiliaria_app/domain/entities/impulso_property.dart';

abstract class ImpulsoPropertyRepository {
 Future<List<ImpulsoProperty>> getImpulsos();
}
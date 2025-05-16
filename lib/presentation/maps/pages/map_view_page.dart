import 'package:flutter/material.dart';
import 'package:inmobiliaria_app/presentation/maps/widgets/map_widget.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';

class PropertyMapView extends StatelessWidget {
  final List<Property> properties;

  const PropertyMapView({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return MapWidget(properties: properties);
  }
}

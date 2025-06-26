import 'package:flutter/material.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/presentation/catalog/explore_card.dart'; // suponiendo que existe


class ExploreCardWrapper extends StatelessWidget {
  final Property property;
  final bool esImpulsado;

  const ExploreCardWrapper({
    Key? key,
    required this.property,
    required this.esImpulsado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ExploreCard(
          location: property.ubicacion?['direccion'] ?? '',
          title: property.descripcion,
          rating: '0',
          path: property.imagenes?.isNotEmpty == true ? property.imagenes![0] : '',
          isHeart: false,
          property: property,
          realStateName: property.inmobiliaria ?? '',
        ),
        if (esImpulsado)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.orange,
              child: Text(
                'Impulsado',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
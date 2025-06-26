import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/domain/entities/impulso_property.dart';
import 'package:inmobiliaria_app/domain/providers/property_provider.dart';
import 'package:inmobiliaria_app/domain/providers/impulsar_property_provider.dart';
import 'package:inmobiliaria_app/presentation/catalog/explore_card.dart';

class ImpulsoPreviewPage extends ConsumerWidget {
  const ImpulsoPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertiesProvider);
    final impulsosAsync = ref.watch(impulsoPropertiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vista de Impulsos')),
      body: propertiesAsync.when(
        data: (properties) {
          return impulsosAsync.when(
            data: (impulsos) {
              final now = DateTime.now();
              final idsImpulsados = impulsos
                  .where((i) =>
                      i.status == 'activo' && i.endDate.isAfter(now))
                  .map((i) => i.property?.id)
                  .toSet();

              return ListView.builder(
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final prop = properties[index];
                  final esImpulsado = idsImpulsados.contains(prop.id);

                  return Stack(
                    children: [
                      ExploreCard(
                        location: prop.ubicacion?['name'] ?? 'Ubicación desconocida',
                        title: prop.descripcion,
                        rating: '5.0', // Si tienes un rating real, úsalo
                        path: prop.imagenes?.isNotEmpty == true
                            ? prop.imagenes![0]
                            : '',
                        isHeart: false,
                        property: prop,
                        realStateName: prop.inmobiliaria ?? '',
                      ),
                      if (esImpulsado)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
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
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error impulsos: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error propiedades: $e')),
      ),
    );
  }
}
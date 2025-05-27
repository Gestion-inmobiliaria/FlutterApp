import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/presentation/maps/widgets/map_filter_sheet.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:inmobiliaria_app/presentation/maps/providers/tile_cache_provider.dart';
import 'package:inmobiliaria_app/presentation/catalog/pages/property_detail_page.dart';

class MapWidget extends StatefulWidget {
  final List<Property> properties;

  const MapWidget({super.key, required this.properties});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  double? maxPrice;
  int? minRooms;
  String? estado;
  String? modalidad;
  String? categoria;
  double? maxDistanceKm; // por ejemplo 10km
  Property? selectedProperty;

  String _getImageForProperty(Property property) {
    final index = widget.properties.indexWhere((p) => p.id == property.id);
    return _assetImages[index % _assetImages.length];
  }

  String _getIconForProperty(Property property) {
    final name = property.inmobiliaria?.toLowerCase() ?? '';

    if (name.contains('remax')) return 'assets/icons/remax.png';
    if (name.contains('century') || name.contains('c21'))
      return 'assets/icons/c21.png';

    return 'assets/icons/default.png';
  }

  // Lista de imágenes disponibles en assets
  final List<String> _assetImages = [
    'assets/images/property.jpg',
    'assets/images/property1.jpg',
    'assets/images/property2.jpg',
    'assets/images/product1.png',
    'assets/images/product2.png',
    'assets/images/product3.png',
    'assets/images/product4.png',
  ];

  late List<Property> filteredProperties;
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    filteredProperties = widget.properties;
    _determinePosition();
  }

  void _applyFilters() {
    final Distance distance = const Distance();

    setState(() {
      filteredProperties =
          widget.properties.where((p) {
            final hasCoords =
                p.ubicacion?['latitud'] != null &&
                p.ubicacion?['longitud'] != null;
            if (!hasCoords) return false;

            final priceMatch = maxPrice == null || p.precio <= maxPrice!;
            final roomsMatch =
                minRooms == null || (p.nroHabitaciones ?? 0) >= minRooms!;
            final estadoMatch = estado == null || p.estado == estado;
            final modalidadMatch =
                modalidad == null ||
                (p.modalidad != null &&
                    p.modalidad!.trim().toLowerCase() ==
                        modalidad!.trim().toLowerCase());

            final categoriaMatch =
                categoria == null ||
                (p.categoria != null &&
                    p.categoria!.trim().toLowerCase() ==
                        categoria!.trim().toLowerCase());

            final isWithinDistance =
                userLocation == null || maxDistanceKm == null
                    ? true
                    : distance(
                          userLocation!,
                          LatLng(
                            double.parse(p.ubicacion!['latitud']),
                            double.parse(p.ubicacion!['longitud']),
                          ),
                        ) <=
                        maxDistanceKm! * 1000;

            return priceMatch &&
                roomsMatch &&
                estadoMatch &&
                modalidadMatch &&
                categoriaMatch &&
                isWithinDistance;
          }).toList();
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(position.latitude, position.longitude);

    if (!mounted) return;

    setState(() {
      userLocation = userLatLng;
    });

    _mapController.move(userLatLng, 15.0);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => MapFilterSheet(
            maxPrice: maxPrice,
            minRooms: minRooms,
            estado: estado,
            modalidad: modalidad,
            categoria: categoria,
            maxDistance: maxDistanceKm,
            onApply: ({
              double? maxPrice,
              int? minRooms,
              String? estado,
              String? modalidad,
              String? categoria,
              double? maxDistance,
            }) {
              setState(() {
                this.maxPrice = maxPrice;
                this.minRooms = minRooms;
                this.estado = estado;
                this.modalidad = modalidad;
                this.categoria = categoria;
                this.maxDistanceKm = maxDistance;
              });
              _applyFilters();
            },
            onClear: () {
              setState(() {
                maxPrice = null;
                minRooms = null;
                estado = null;
                modalidad = null;
                categoria = null;
                maxDistanceKm = null;
                filteredProperties = widget.properties;
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLocation ?? const LatLng(-17.783389, -63.181032),
            initialZoom: 13.0,
            onTap: (_, __) => _popupController.hideAllPopups(),
          ),
          children: [
            Consumer(
              builder: (context, ref, _) {
                final asyncStore = ref.watch(tileCacheProvider);
                return asyncStore.when(
                  data: (store) {
                    return TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: CachedTileProvider(
                        store: store, // Este sí es válido
                        maxStale: const Duration(days: 365),
                      ),
                      userAgentPackageName: 'com.example.app',
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (err, _) => Center(child: Text('Error: $err')),
                );
              },
            ),
            if (userLocation != null && maxDistanceKm != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: userLocation!,
                    radius: maxDistanceKm! * 1000,
                    color: Colors.blue.withOpacity(0.15),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                    useRadiusInMeter: true,
                  ),
                ],
              ),
            MarkerLayer(
              markers:
                  filteredProperties
                      .where(
                        (p) =>
                            p.ubicacion?['latitud'] != null &&
                            p.ubicacion?['longitud'] != null,
                      )
                      .map(
                        (p) => Marker(
                          key: ValueKey(p.id),
                          width: 40,
                          height: 40,
                          point: LatLng(
                            double.parse(p.ubicacion!['latitud']),
                            double.parse(p.ubicacion!['longitud']),
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedProperty = p),
                            child: Image.asset(
                              _getIconForProperty(
                                p,
                              ), // ← ícono por inmobiliaria
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),

            if (userLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: userLocation!,
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 36,
                    ),
                  ),
                ],
              ),
          ],
        ),

        Positioned(
          top: 16,
          left: 16,
          child: ElevatedButton.icon(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
            label: const Text('Filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 3,
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            onPressed: () {
              if (userLocation != null) {
                _mapController.move(userLocation!, 15.0);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ubicación del usuario no disponible'),
                  ),
                );
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ),
        if (userLocation != null && maxDistanceKm != null)
          Positioned(
            top: 70,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Radio: ${maxDistanceKm!.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (selectedProperty != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        selectedProperty!.imagenes!.isNotEmpty
                            ? Image.network(
                              selectedProperty!.imagenes!.first,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'assets/images/default_property.jpg',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedProperty!.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedProperty!.estado,
                        style: TextStyle(
                          color:
                              selectedProperty!.estado.toLowerCase() ==
                                      'disponible'
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                      Text(
                        "\$${selectedProperty!.precio}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (selectedProperty!.ubicacion?['direccion'] != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedProperty!.ubicacion!['direccion'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed:
                            () => setState(() => selectedProperty = null),
                        child: const Text("Cerrar"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PropertyDetailPage(
                                    property: selectedProperty!,
                                    imagePath:
                                        selectedProperty!
                                                    .imagenes
                                                    ?.isNotEmpty ==
                                                true
                                            ? selectedProperty!.imagenes!.first
                                            : 'assets/images/default_property.jpg',
                                    isNetworkImage:
                                        selectedProperty!
                                            .imagenes
                                            ?.isNotEmpty ==
                                        true,
                                    realStateName:
                                        selectedProperty!.inmobiliaria ?? '',
                                  ),
                            ),
                          );
                        },
                        child: const Text("Ver detalles"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

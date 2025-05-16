import 'package:flutter/material.dart';

class MapFilterSheet extends StatefulWidget {
  final double? maxPrice;
  final int? minRooms;
  final String? estado;
  final String? modalidad;
  final String? categoria;
  final double? maxDistance;
  final void Function({
    double? maxPrice,
    int? minRooms,
    String? estado,
    String? modalidad,
    String? categoria,
    double? maxDistance,
  })
  onApply;
  final VoidCallback onClear;

  const MapFilterSheet({
    super.key,
    this.maxPrice,
    this.minRooms,
    this.estado,
    this.modalidad,
    this.categoria,
    this.maxDistance,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  late double tempMaxPrice;
  late int tempMinRooms;
  String? tempEstado;
  String? tempModalidad;
  String? tempCategoria;
  double tempMaxDistance = 0;

  @override
  void initState() {
    super.initState();
    tempMaxPrice = widget.maxPrice ?? 500000;
    tempMinRooms = widget.minRooms ?? 0;
    tempEstado = widget.estado;
    tempModalidad = widget.modalidad;
    tempCategoria = widget.categoria;
    tempMaxDistance = widget.maxDistance ?? 0;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filtros de búsqueda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          spacing,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Precio máximo"),
              Slider(
                value: tempMaxPrice,
                min: 10000,
                max: 500000,
                divisions: 100,
                label: '\$${tempMaxPrice.round()}',
                onChanged: (value) => setState(() => tempMaxPrice = value),
              ),
            ],
          ),
          spacing,
          DropdownButtonFormField<int>(
            value: tempMinRooms,
            decoration: _inputDecoration("Habitaciones mínimas"),
            items:
                [0, 1, 2, 3, 4, 5]
                    .map(
                      (v) =>
                          DropdownMenuItem(value: v, child: Text(v.toString())),
                    )
                    .toList(),
            onChanged: (v) => setState(() => tempMinRooms = v ?? 0),
          ),
          spacing,
          DropdownButtonFormField<String>(
            value: tempEstado,
            decoration: _inputDecoration("Estado"),
            isExpanded: true,
            hint: const Text("Todos"),
            items:
                ['disponible', 'ocupado']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (v) => setState(() => tempEstado = v),
          ),
          spacing,
          DropdownButtonFormField<String>(
            value: tempModalidad,
            decoration: _inputDecoration("Modalidad"),
            isExpanded: true,
            hint: const Text("Todas"),
            items:
                ['Venta', 'Anticrético', 'Alquiler']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (v) => setState(() => tempModalidad = v),
          ),
          spacing,
          DropdownButtonFormField<String>(
            value: tempCategoria,
            decoration: _inputDecoration("Categoría"),
            isExpanded: true,
            hint: const Text("Todas"),
            items:
                ['Casa', 'Departamento', 'Terreno']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (v) => setState(() => tempCategoria = v),
          ),
          spacing,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Distancia máxima (radio)"),
              Slider(
                value: tempMaxDistance,
                min: 0,
                max: 20.0,
                divisions: 40, // pasos de 0.5 km
                label:
                    tempMaxDistance == 0
                        ? "Sin filtro"
                        : "${tempMaxDistance.toStringAsFixed(1)} km",
                onChanged: (value) => setState(() => tempMaxDistance = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    widget.onApply(
                      maxPrice: tempMaxPrice,
                      minRooms: tempMinRooms,
                      estado: tempEstado,
                      modalidad: tempModalidad,
                      categoria: tempCategoria,
                      maxDistance:
                          tempMaxDistance == 0 ? null : tempMaxDistance,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: const Text("Aplicar"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: const Text("Limpiar"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

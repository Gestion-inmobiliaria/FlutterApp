import 'package:flutter/material.dart';
import 'package:inmobiliaria_app/presentation/constant/colors.dart';

class PropertyFilter {
  final RangeValues? priceRange;
  final String? location;
  final RangeValues? areaRange;
  final int? minBedrooms;
  final int? minBathrooms;
  final int? minParkingSpots;
  final bool isActive;

  const PropertyFilter({
    this.priceRange,
    this.location,
    this.areaRange,
    this.minBedrooms,
    this.minBathrooms,
    this.minParkingSpots,
    this.isActive = false,
  });

  PropertyFilter copyWith({
    RangeValues? priceRange,
    String? location,
    RangeValues? areaRange,
    int? minBedrooms,
    int? minBathrooms,
    int? minParkingSpots,
    bool? isActive,
  }) {
    return PropertyFilter(
      priceRange: priceRange ?? this.priceRange,
      location: location ?? this.location,
      areaRange: areaRange ?? this.areaRange,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      minParkingSpots: minParkingSpots ?? this.minParkingSpots,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    List<String> activeFilters = [];

    if (priceRange != null) {
      activeFilters.add('Precio: ${priceRange!.start.toInt()}€ - ${priceRange!.end.toInt()}€');
    }
    if (location != null && location!.isNotEmpty) {
      activeFilters.add('Ubicación: $location');
    }
    if (areaRange != null) {
      activeFilters.add('Área: ${areaRange!.start.toInt()}m² - ${areaRange!.end.toInt()}m²');
    }
    if (minBedrooms != null && minBedrooms! > 0) {
      activeFilters.add('Habitaciones: $minBedrooms+');
    }
    if (minBathrooms != null && minBathrooms! > 0) {
      activeFilters.add('Baños: $minBathrooms+');
    }
    if (minParkingSpots != null && minParkingSpots! > 0) {
      activeFilters.add('Estacionamientos: $minParkingSpots+');
    }

    return activeFilters.join(', ');
  }
}

class FilterPage extends StatefulWidget {
  final PropertyFilter initialFilter;

  const FilterPage({
    Key? key,
    required this.initialFilter,
  }) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late RangeValues _priceRange;
  late TextEditingController _locationController;
  late RangeValues _areaRange;
  late int _minBedrooms;
  late int _minBathrooms;
  late int _minParkingSpots;

  // Valores constantes para los rangos
  static const double MIN_PRICE = 0;
  static const double MAX_PRICE = 1000000;
  static const double MIN_AREA = 0;
  static const double MAX_AREA = 500;

  @override
  void initState() {
    super.initState();
    // Inicializar con valores del filtro actual o valores predeterminados
    _priceRange = widget.initialFilter.priceRange ?? const RangeValues(MIN_PRICE, MAX_PRICE);
    _locationController = TextEditingController(text: widget.initialFilter.location ?? '');
    _areaRange = widget.initialFilter.areaRange ?? const RangeValues(MIN_AREA, MAX_AREA);
    _minBedrooms = widget.initialFilter.minBedrooms ?? 0;
    _minBathrooms = widget.initialFilter.minBathrooms ?? 0;
    _minParkingSpots = widget.initialFilter.minParkingSpots ?? 0;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filtrar propiedades',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Botón para limpiar todos los filtros
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Limpiar',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rango de precios
              _buildSectionTitle('Rango de precio'),
              const SizedBox(height: 8),
              _buildPriceRangeSlider(),
              _buildPriceLabels(),
              const SizedBox(height: 24),

              // Ubicación
              _buildSectionTitle('Ubicación'),
              const SizedBox(height: 8),
              _buildLocationTextField(),
              const SizedBox(height: 24),

              // Rango de área
              _buildSectionTitle('Área (m²)'),
              const SizedBox(height: 8),
              _buildAreaRangeSlider(),
              _buildAreaLabels(),
              const SizedBox(height: 24),

              // Número de habitaciones
              _buildSectionTitle('Habitaciones'),
              const SizedBox(height: 8),
              _buildCountSelector(
                'Mínimo de habitaciones',
                _minBedrooms,
                (value) => setState(() => _minBedrooms = value),
              ),
              const SizedBox(height: 24),

              // Número de baños
              _buildSectionTitle('Baños'),
              const SizedBox(height: 8),
              _buildCountSelector(
                'Mínimo de baños',
                _minBathrooms,
                (value) => setState(() => _minBathrooms = value),
              ),
              const SizedBox(height: 24),

              // Número de estacionamientos
              _buildSectionTitle('Estacionamientos'),
              const SizedBox(height: 8),
              _buildCountSelector(
                'Mínimo de estacionamientos',
                _minParkingSpots,
                (value) => setState(() => _minParkingSpots = value),
              ),
              const SizedBox(height: 32),

              // Botón para aplicar filtros
              _buildApplyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPriceRangeSlider() {
    return RangeSlider(
      min: MIN_PRICE,
      max: MAX_PRICE,
      divisions: 100,
      labels: RangeLabels(
        '${_priceRange.start.toInt()}€',
        '${_priceRange.end.toInt()}€',
      ),
      values: _priceRange,
      activeColor: AppColors.primaryColor,
      inactiveColor: AppColors.primaryColor.withOpacity(0.2),
      onChanged: (RangeValues values) {
        setState(() {
          _priceRange = values;
        });
      },
    );
  }

  Widget _buildPriceLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_priceRange.start.toInt()}€',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${_priceRange.end.toInt()}€',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTextField() {
    return TextField(
      controller: _locationController,
      decoration: InputDecoration(
        hintText: 'Ej: Madrid, Barcelona, Valencia...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        prefixIcon: const Icon(Icons.location_on_outlined),
      ),
    );
  }

  Widget _buildAreaRangeSlider() {
    return RangeSlider(
      min: MIN_AREA,
      max: MAX_AREA,
      divisions: 50,
      labels: RangeLabels(
        '${_areaRange.start.toInt()}m²',
        '${_areaRange.end.toInt()}m²',
      ),
      values: _areaRange,
      activeColor: AppColors.primaryColor,
      inactiveColor: AppColors.primaryColor.withOpacity(0.2),
      onChanged: (RangeValues values) {
        setState(() {
          _areaRange = values;
        });
      },
    );
  }

  Widget _buildAreaLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_areaRange.start.toInt()}m²',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${_areaRange.end.toInt()}m²',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountSelector(
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: value > 0
                    ? () => onChanged(value - 1)
                    : null,
                color: value > 0 ? AppColors.primaryColor : Colors.grey,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => onChanged(value + 1),
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _applyFilters,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Aplicar filtros',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(MIN_PRICE, MAX_PRICE);
      _locationController.clear();
      _areaRange = const RangeValues(MIN_AREA, MAX_AREA);
      _minBedrooms = 0;
      _minBathrooms = 0;
      _minParkingSpots = 0;
    });
  }

  void _applyFilters() {
    // Verificar si hay algún filtro activo
    final bool isAnyFilterActive = _isAnyFilterActive();
    
    // Crear un nuevo filtro con los valores actuales
    final filter = PropertyFilter(
      priceRange: _isPriceFilterActive() ? _priceRange : null,
      location: _isLocationFilterActive() ? _locationController.text : null,
      areaRange: _isAreaFilterActive() ? _areaRange : null,
      minBedrooms: _minBedrooms > 0 ? _minBedrooms : null,
      minBathrooms: _minBathrooms > 0 ? _minBathrooms : null,
      minParkingSpots: _minParkingSpots > 0 ? _minParkingSpots : null,
      isActive: isAnyFilterActive,
    );

    // Devolver el filtro actualizado
    Navigator.pop(context, filter);
  }

  bool _isPriceFilterActive() {
    return _priceRange.start > MIN_PRICE || _priceRange.end < MAX_PRICE;
  }

  bool _isLocationFilterActive() {
    return _locationController.text.isNotEmpty;
  }

  bool _isAreaFilterActive() {
    return _areaRange.start > MIN_AREA || _areaRange.end < MAX_AREA;
  }

  bool _isAnyFilterActive() {
    return _isPriceFilterActive() ||
        _isLocationFilterActive() ||
        _isAreaFilterActive() ||
        _minBedrooms > 0 ||
        _minBathrooms > 0 ||
        _minParkingSpots > 0;
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/data/sources/property_remote_datasource.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_event.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_state.dart';
import 'package:inmobiliaria_app/presentation/catalog/pages/filter_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final PropertyRemoteDatasource _propertyDatasource;
  List<Property> _allProperties = [];
  String _currentRealStateId = '';
  String _currentRealStateName = '';

  PropertyBloc({required PropertyRemoteDatasource propertyDatasource})
    : _propertyDatasource = propertyDatasource,
      super(PropertyInitial()) {
    on<LoadProperties>(_onLoadProperties);
    on<LoadPropertiesWithLocation>(_onLoadPropertiesWithLocation);
    on<LoadPropertyDetail>(_onLoadPropertyDetail);
    on<SearchProperties>(_onSearchProperties);
    on<ToggleFavorite>(_onToggleFavorite);
    on<ApplyFilters>(_onApplyFilters);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadProperties(
    LoadProperties event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    try {
      _currentRealStateId = event.realStateId;
      _currentRealStateName = event.realStateName;

      debugPrint(
        'Cargando propiedades para inmobiliaria: $_currentRealStateId',
      );

      // Verificamos si hay token de usuario
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Si no hay token, mostramos mensaje de login opcional
      if (token == null || token.isEmpty) {
        debugPrint('No hay token. Usuario no autenticado.');
      }

      final properties = await _propertyDatasource.fetchPropertiesByRealState(
        event.realStateId,
      );
      _allProperties = properties;

      debugPrint('Propiedades cargadas: ${properties.length}');
      emit(
        PropertyLoaded(
          properties: properties,
          realStateId: event.realStateId,
          realStateName: event.realStateName,
        ),
      );
    } catch (e) {
      debugPrint('Error al cargar propiedades: $e');

      if (e.toString().contains('401') ||
          e.toString().contains('no autorizado')) {
        // Error de autenticación, mostrar propiedades de muestra
        final mockProperties = _getMockProperties();
        _allProperties = mockProperties;

        emit(
          PropertyLoaded(
            properties: mockProperties,
            realStateId: event.realStateId,
            realStateName: event.realStateName,
            isAuthError: true,
            authErrorMessage:
                'Sesión no iniciada o expirada. Mostrando datos de ejemplo.',
          ),
        );
      } else {
        // Otro tipo de error
        emit(PropertyError(e.toString()));
      }
    }
  }

  Future<void> _onLoadPropertyDetail(
    LoadPropertyDetail event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      // Si ya tenemos las propiedades cargadas, buscamos en la lista local
      if (_allProperties.isNotEmpty) {
        final property = _allProperties.firstWhere(
          (p) => p.id == event.propertyId,
          orElse: () => throw Exception('Propiedad no encontrada'),
        );

        emit(PropertyDetailLoaded(property));
      } else {
        // TODO: Implementar carga individual de propiedad desde API
        throw Exception('No hay propiedades cargadas');
      }
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }

  void _onSearchProperties(
    SearchProperties event,
    Emitter<PropertyState> emit,
  ) {
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;
      final query = event.query.toLowerCase();

      // Verificar si hay filtros activos realmente
      final hasActiveFilters =
          currentState.activeFilter != null &&
          currentState.activeFilter!.isActive;

      if (query.isEmpty) {
        // Si la búsqueda está vacía, simplemente aplicamos los filtros activos si hay
        if (hasActiveFilters) {
          final filteredProperties = _applyFilterToProperties(
            _allProperties,
            currentState.activeFilter!,
          );

          emit(currentState.copyWith(filteredProperties: filteredProperties));
        } else {
          // Sin filtros y sin búsqueda, mostrar todas
          emit(currentState.copyWith(filteredProperties: _allProperties));
        }
      } else {
        // Filtrar por búsqueda
        List<Property> searchResults =
            _allProperties.where((property) {
              final matchesDescription = property.descripcion
                  .toLowerCase()
                  .contains(query);
              final matchesLocation =
                  property.ubicacion != null &&
                  property.ubicacion!['direccion'] != null &&
                  property.ubicacion!['direccion']
                      .toString()
                      .toLowerCase()
                      .contains(query);

              return matchesDescription || matchesLocation;
            }).toList();

        // Si hay filtros activos, aplicarlos sobre los resultados de búsqueda
        if (hasActiveFilters) {
          searchResults = _applyFilterToProperties(
            searchResults,
            currentState.activeFilter!,
          );
        }

        emit(currentState.copyWith(filteredProperties: searchResults));
      }
    }
  }

  void _onToggleFavorite(ToggleFavorite event, Emitter<PropertyState> emit) {
    // Aquí se implementaría la lógica para marcar/desmarcar favoritos
    // Por ahora solo manejamos el estado actual
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;
      emit(currentState);
    }
  }

  void _onApplyFilters(ApplyFilters event, Emitter<PropertyState> emit) {
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;
      final filteredProperties = _applyFilterToProperties(
        _allProperties,
        event.filter,
      );

      emit(
        currentState.copyWith(
          activeFilter: event.filter,
          filteredProperties: filteredProperties,
        ),
      );
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<PropertyState> emit) {
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;

      // Asegurarse de que activeFilter sea null y se muestren todas las propiedades
      emit(
        PropertyLoaded(
          properties: _allProperties,
          realStateId: currentState.realStateId,
          realStateName: currentState.realStateName,
          isAuthError: currentState.isAuthError,
          authErrorMessage: currentState.authErrorMessage,
          activeFilter: null,
          filteredProperties: _allProperties,
        ),
      );
    }
  }

  List<Property> _applyFilterToProperties(
    List<Property> properties,
    PropertyFilter filter,
  ) {
    return properties.where((property) {
      // Filtro de precio
      if (filter.priceRange != null) {
        if (property.precio < filter.priceRange!.start ||
            property.precio > filter.priceRange!.end) {
          return false;
        }
      }

      // Filtro de ubicación
      if (filter.location != null && filter.location!.isNotEmpty) {
        final String locationQuery = filter.location!.toLowerCase();
        final bool locationMatches =
            property.ubicacion != null &&
            property.ubicacion!['direccion'] != null &&
            property.ubicacion!['direccion'].toString().toLowerCase().contains(
              locationQuery,
            );

        if (!locationMatches) {
          return false;
        }
      }

      // Filtro de área
      if (filter.areaRange != null) {
        if (property.area < filter.areaRange!.start ||
            property.area > filter.areaRange!.end) {
          return false;
        }
      }

      // Filtro de habitaciones
      if (filter.minBedrooms != null && filter.minBedrooms! > 0) {
        if (property.nroHabitaciones == null ||
            property.nroHabitaciones! < filter.minBedrooms!) {
          return false;
        }
      }

      // Filtro de baños
      if (filter.minBathrooms != null && filter.minBathrooms! > 0) {
        if (property.nroBanos == null ||
            property.nroBanos! < filter.minBathrooms!) {
          return false;
        }
      }

      // Filtro de estacionamientos
      if (filter.minParkingSpots != null && filter.minParkingSpots! > 0) {
        if (property.nroEstacionamientos == null ||
            property.nroEstacionamientos! < filter.minParkingSpots!) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _onLoadPropertiesWithLocation(
    LoadPropertiesWithLocation event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    try {
      final properties = await _propertyDatasource
          .fetchPropertiesWithLocationByRealState(event.realStateId);
      print('properties dasdasda: $properties.length');
      _currentRealStateId = event.realStateId;
      final propertiesWithLocation =
          properties.where((p) {
            final lat = p.ubicacion?['latitud'];
            final lng = p.ubicacion?['longitud'];
            return lat != null &&
                lng != null &&
                lat.toString().isNotEmpty &&
                lng.toString().isNotEmpty;
          }).toList();

      emit(
        PropertyLoaded(
          properties: propertiesWithLocation,
          realStateId: event.realStateId,
          realStateName: _currentRealStateName,
        ),
      );
    } catch (e) {
      emit(PropertyError('Error al cargar propiedades con ubicación: $e'));
    }
  }

  // Proporciona propiedades de muestra en caso de error de autenticación
  List<Property> _getMockProperties() {
    debugPrint('Generando propiedades de muestra para mostrar al usuario');
    return [
      Property(
        id: '1',
        descripcion: 'Apartamento de lujo en zona céntrica',
        precio: 150000,
        estado: 'disponible',
        area: 120,
        nroHabitaciones: 3,
        nroBanos: 2,
        nroEstacionamientos: 1,
        ubicacion: {'direccion': 'Av. Principal #123, Madrid'},
        imagenes: ['https://via.placeholder.com/300x200?text=Apartamento'],
      ),
      Property(
        id: '2',
        descripcion: 'Casa amplia con jardín',
        precio: 250000,
        estado: 'disponible',
        area: 230,
        nroHabitaciones: 4,
        nroBanos: 3,
        nroEstacionamientos: 2,
        ubicacion: {'direccion': 'Calle Secundaria #456, Barcelona'},
        imagenes: ['https://via.placeholder.com/300x200?text=Casa'],
      ),
      Property(
        id: '3',
        descripcion: 'Estudio moderno para profesionales',
        precio: 85000,
        estado: 'disponible',
        area: 65,
        nroHabitaciones: 1,
        nroBanos: 1,
        nroEstacionamientos: 0,
        ubicacion: {'direccion': 'Zona Empresarial Bloque C, Valencia'},
        imagenes: ['https://via.placeholder.com/300x200?text=Estudio'],
      ),
      Property(
        id: '4',
        descripcion: 'Chalet de lujo con piscina',
        precio: 450000,
        estado: 'reservado',
        area: 320,
        nroHabitaciones: 5,
        nroBanos: 4,
        nroEstacionamientos: 3,
        ubicacion: {'direccion': 'Urbanización Exclusiva #78, Málaga'},
        imagenes: ['https://via.placeholder.com/300x200?text=Chalet'],
      ),
      Property(
        id: '5',
        descripcion: 'Loft industrial renovado',
        precio: 175000,
        estado: 'disponible',
        area: 95,
        nroHabitaciones: 2,
        nroBanos: 1,
        nroEstacionamientos: 1,
        ubicacion: {'direccion': 'Antigua Fábrica Loft #3, Sevilla'},
        imagenes: ['https://via.placeholder.com/300x200?text=Loft'],
      ),
    ];
  }
}

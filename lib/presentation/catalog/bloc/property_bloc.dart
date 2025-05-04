import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/data/sources/property_remote_datasource.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_event.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final PropertyRemoteDatasource _propertyDatasource;
  List<Property> _allProperties = [];
  String _currentRealStateId = '';
  String _currentRealStateName = '';

  PropertyBloc({
    required PropertyRemoteDatasource propertyDatasource,
  })  : _propertyDatasource = propertyDatasource,
        super(PropertyInitial()) {
    on<LoadProperties>(_onLoadProperties);
    on<LoadPropertyDetail>(_onLoadPropertyDetail);
    on<SearchProperties>(_onSearchProperties);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadProperties(
    LoadProperties event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    try {
      _currentRealStateId = event.realStateId;
      _currentRealStateName = event.realStateName;
      
      debugPrint('Cargando propiedades para inmobiliaria: $_currentRealStateId');
      
      // Verificamos si hay token de usuario
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      // Si no hay token, mostramos mensaje de login opcional
      if (token == null || token.isEmpty) {
        debugPrint('No hay token. Usuario no autenticado.');
      }
      
      final properties = await _propertyDatasource.fetchPropertiesByRealState(event.realStateId);
      _allProperties = properties;
      
      debugPrint('Propiedades cargadas: ${properties.length}');
      emit(PropertyLoaded(
        properties: properties,
        realStateId: event.realStateId,
        realStateName: event.realStateName,
      ));
    } catch (e) {
      debugPrint('Error en _onLoadProperties: $e');
      String errorMessage = 'Error al cargar propiedades';
      
      if (e.toString().contains('401') || e.toString().contains('No autorizado')) {
        // Si es error de autenticación, mostramos propiedades de muestra
        // para no interrumpir la experiencia del usuario, pero con un mensaje informativo
        debugPrint('Error de autenticación. Mostrando propiedades de muestra');
        final mockProperties = _getMockProperties();
        
        _allProperties = mockProperties;
        emit(PropertyLoaded(
          properties: mockProperties, 
          realStateId: event.realStateId, 
          realStateName: event.realStateName,
          isAuthError: true, // Indicamos que hay error de autenticación
          authErrorMessage: 'Estas son propiedades de ejemplo. Para ver propiedades reales, inicia sesión.',
        ));
        return;
      } 
      
      // Otros tipos de errores
      if (e.toString().contains('realstate.id')) {
        errorMessage = 'Error en la consulta: Verifica que la API espere realstate.id';
      } else if (e.toString().contains('sector.id')) {
        errorMessage = 'Error en la consulta: Verifica que la API espere sector.id';
      } else if (e.toString().contains('Connection refused') || 
                e.toString().contains('SocketException')) {
        errorMessage = 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Recurso no encontrado (404). Verifica la URL de la API.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Error interno del servidor (500). Contacta al administrador.';
      } else if (e.toString().contains('sectores de la inmobiliaria')) {
        errorMessage = 'No se encontraron sectores para esta inmobiliaria. Verifica la estructura de datos.';
      }
      
      emit(PropertyError('$errorMessage\n\nDetalle: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPropertyDetail(
    LoadPropertyDetail event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    try {
      final property = await _propertyDatasource.fetchPropertyDetail(event.propertyId);
      emit(PropertyDetailLoaded(property));
    } catch (e) {
      debugPrint('Error en _onLoadPropertyDetail: $e');
      
      if (e.toString().contains('401') || e.toString().contains('No autorizado')) {
        // Si es error de autenticación, mostramos una propiedad de muestra
        final mockProperty = _getMockProperties().first;
        emit(PropertyDetailLoaded(mockProperty, isAuthError: true));
        return;
      }
      
      emit(PropertyError('Error al cargar detalle de propiedad: ${e.toString()}'));
    }
  }

  void _onSearchProperties(
    SearchProperties event,
    Emitter<PropertyState> emit,
  ) {
    if (_allProperties.isEmpty) {
      emit(const PropertyLoaded(
        properties: [],
        realStateId: '',
        realStateName: '',
      ));
      return;
    }

    if (event.query.isEmpty) {
      emit(PropertyLoaded(
        properties: _allProperties,
        realStateId: _currentRealStateId,
        realStateName: _currentRealStateName,
      ));
      return;
    }

    final filteredProperties = _allProperties.where((property) {
      final descripcion = property.descripcion.toLowerCase();
      final ubicacion = property.ubicacion?['direccion']?.toString().toLowerCase() ?? '';
      final query = event.query.toLowerCase();
      
      return descripcion.contains(query) || ubicacion.contains(query);
    }).toList();

    emit(PropertyLoaded(
      properties: filteredProperties,
      realStateId: _currentRealStateId,
      realStateName: _currentRealStateName,
    ));
  }

  void _onToggleFavorite(
    ToggleFavorite event,
    Emitter<PropertyState> emit,
  ) {
    // Aquí se implementaría la lógica para marcar/desmarcar favoritos
    // Por ahora solo manejamos el estado actual
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;
      emit(PropertyLoaded(
        properties: currentState.properties,
        realStateId: currentState.realStateId,
        realStateName: currentState.realStateName,
      ));
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
        ubicacion: {'direccion': 'Av. Principal #123'},
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
        ubicacion: {'direccion': 'Calle Secundaria #456'},
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
        ubicacion: {'direccion': 'Zona Empresarial Bloque C'},
        imagenes: ['https://via.placeholder.com/300x200?text=Estudio'],
      ),
    ];
  }
} 
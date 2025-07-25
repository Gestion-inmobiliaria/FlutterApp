import 'package:equatable/equatable.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/presentation/catalog/pages/filter_page.dart';

abstract class PropertyState extends Equatable {
  const PropertyState();
  
  @override
  List<Object?> get props => [];
}

class PropertyInitial extends PropertyState {}

class PropertyLoading extends PropertyState {}

class PropertyLoaded extends PropertyState {
  final List<Property> properties;
  final String realStateId;
  final String realStateName;
  final bool isAuthError;
  final String? authErrorMessage;
  final PropertyFilter? activeFilter;
  final List<Property> filteredProperties;

  const PropertyLoaded({
    required this.properties,
    required this.realStateId,
    required this.realStateName,
    this.isAuthError = false,
    this.authErrorMessage,
    this.activeFilter,
    List<Property>? filteredProperties,
  }) : filteredProperties = filteredProperties ?? properties;

  @override
  List<Object?> get props => [
    properties, 
    realStateId, 
    realStateName, 
    isAuthError, 
    authErrorMessage, 
    activeFilter,
    filteredProperties,
  ];

  PropertyLoaded copyWith({
    List<Property>? properties,
    String? realStateId,
    String? realStateName,
    bool? isAuthError,
    String? authErrorMessage,
    PropertyFilter? activeFilter,
    List<Property>? filteredProperties,
  }) {
    return PropertyLoaded(
      properties: properties ?? this.properties,
      realStateId: realStateId ?? this.realStateId,
      realStateName: realStateName ?? this.realStateName,
      isAuthError: isAuthError ?? this.isAuthError,
      authErrorMessage: authErrorMessage ?? this.authErrorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
      filteredProperties: filteredProperties ?? this.filteredProperties,
    );
  }
}

class PropertyError extends PropertyState {
  final String message;

  const PropertyError(this.message);

  @override
  List<Object?> get props => [message];
}

class PropertyDetailLoaded extends PropertyState {
  final Property property;
  final bool isAuthError;

  const PropertyDetailLoaded(this.property, {this.isAuthError = false});

  @override
  List<Object?> get props => [property, isAuthError];
} 
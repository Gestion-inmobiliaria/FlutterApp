import 'package:equatable/equatable.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';

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

  const PropertyLoaded({
    required this.properties,
    required this.realStateId,
    required this.realStateName,
    this.isAuthError = false,
    this.authErrorMessage,
  });

  @override
  List<Object?> get props => [properties, realStateId, realStateName, isAuthError, authErrorMessage];
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
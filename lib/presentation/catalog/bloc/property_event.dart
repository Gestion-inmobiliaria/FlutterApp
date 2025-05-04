import 'package:equatable/equatable.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class LoadProperties extends PropertyEvent {
  final String realStateId;
  final String realStateName;

  const LoadProperties({
    required this.realStateId,
    required this.realStateName,
  });

  @override
  List<Object?> get props => [realStateId, realStateName];
}

class LoadPropertyDetail extends PropertyEvent {
  final String propertyId;

  const LoadPropertyDetail(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class SearchProperties extends PropertyEvent {
  final String query;

  const SearchProperties(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleFavorite extends PropertyEvent {
  final String propertyId;

  const ToggleFavorite(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
} 
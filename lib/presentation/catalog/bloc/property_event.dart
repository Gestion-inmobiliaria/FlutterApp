import 'package:equatable/equatable.dart';
import 'package:inmobiliaria_app/presentation/catalog/pages/filter_page.dart';

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

class LoadPropertiesWithLocation extends PropertyEvent {
  final String realStateId;

  const LoadPropertiesWithLocation({required this.realStateId});
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
  final bool isFavorite;

  const ToggleFavorite({required this.propertyId, required this.isFavorite});

  @override
  List<Object?> get props => [propertyId, isFavorite];
}

class ApplyFilters extends PropertyEvent {
  final PropertyFilter filter;

  const ApplyFilters(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ClearFilters extends PropertyEvent {}

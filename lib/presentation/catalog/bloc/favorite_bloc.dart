import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/domain/usecases/favorite_usecases.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class FavoriteEvent {}

class LoadFavorites extends FavoriteEvent {
  final String? realStateId;
  LoadFavorites({this.realStateId});
}

class AddToFavorites extends FavoriteEvent {
  final String propertyId;
  AddToFavorites(this.propertyId);
}

class RemoveFromFavorites extends FavoriteEvent {
  final String propertyId;
  RemoveFromFavorites(this.propertyId);
}

class CheckFavoriteStatus extends FavoriteEvent {
  final String propertyId;
  CheckFavoriteStatus(this.propertyId);
}

class ToggleFavorite extends FavoriteEvent {
  final String propertyId;
  final bool isCurrentlyFavorite;
  ToggleFavorite(this.propertyId, this.isCurrentlyFavorite);
}

class ClearFavorites extends FavoriteEvent {}

class LoadFavoriteStatus extends FavoriteEvent {
  final List<String> propertyIds;
  LoadFavoriteStatus(this.propertyIds);
}

// States
abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<Property> favorites;
  final Map<String, bool> favoriteStatus;
  
  FavoriteLoaded({
    required this.favorites,
    required this.favoriteStatus,
  });
  
  FavoriteLoaded copyWith({
    List<Property>? favorites,
    Map<String, bool>? favoriteStatus,
  }) {
    return FavoriteLoaded(
      favorites: favorites ?? this.favorites,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
    );
  }
}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);
}

class FavoriteActionSuccess extends FavoriteState {
  final String message;
  final bool isAdded;
  FavoriteActionSuccess(this.message, this.isAdded);
}

// Bloc
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final AddToFavoritesUseCase addToFavoritesUseCase;
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final GetFavoritesByRealStateUseCase getFavoritesByRealStateUseCase;
  final CheckIsFavoriteUseCase checkIsFavoriteUseCase;

  FavoriteBloc({
    required this.addToFavoritesUseCase,
    required this.removeFromFavoritesUseCase,
    required this.getFavoritesUseCase,
    required this.getFavoritesByRealStateUseCase,
    required this.checkIsFavoriteUseCase,
  }) : super(FavoriteInitial()) {
    
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
    on<ToggleFavorite>(_onToggleFavorite);
    on<ClearFavorites>(_onClearFavorites);
    on<LoadFavoriteStatus>(_onLoadFavoriteStatus);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    debugPrint('🔥 Token recuperado de SharedPreferences: ${token != null ? "Presente" : "Ausente"}');
    return token;
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoading());
    
    try {
      final token = await _getToken();
      if (token == null) {
        emit(FavoriteLoaded(favorites: [], favoriteStatus: {}));
        return;
      }

      final List<Property> favorites;
      if (event.realStateId != null) {
        favorites = await getFavoritesByRealStateUseCase(event.realStateId!, token);
      } else {
        favorites = await getFavoritesUseCase(token);
      }

      // Crear mapa de estado de favoritos
      final Map<String, bool> favoriteStatus = {};
      for (final property in favorites) {
        favoriteStatus[property.id] = true;
      }

      emit(FavoriteLoaded(favorites: favorites, favoriteStatus: favoriteStatus));
    } catch (e) {
      emit(FavoriteError('Error al cargar favoritos: ${e.toString()}'));
    }
  }

  Future<void> _onAddToFavorites(AddToFavorites event, Emitter<FavoriteState> emit) async {
    debugPrint('🔥 _onAddToFavorites - PropertyId: ${event.propertyId}');
    
    try {
      final token = await _getToken();
      debugPrint('🔥 Token obtenido: ${token != null ? "Presente" : "Ausente"}');
      
      if (token == null) {
        debugPrint('🔥 No hay token, emitiendo error');
        emit(FavoriteError('No estás autenticado'));
        return;
      }

      debugPrint('🔥 Llamando al use case...');
      await addToFavoritesUseCase(event.propertyId, token);
      
      // Actualizar el estado local SIEMPRE
      if (state is FavoriteLoaded) {
        final currentState = state as FavoriteLoaded;
        final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[event.propertyId] = true;
        
        emit(currentState.copyWith(favoriteStatus: updatedStatus));
      } else {
        // Si no hay estado cargado, crear uno nuevo
        emit(FavoriteLoaded(
          favorites: [],
          favoriteStatus: {event.propertyId: true},
        ));
      }
      
      debugPrint('🔥 Favorito agregado exitosamente');
    } catch (e) {
      debugPrint('🔥 Error al agregar favorito: $e');
      emit(FavoriteError('Error al agregar a favoritos: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveFromFavorites(RemoveFromFavorites event, Emitter<FavoriteState> emit) async {
    try {
      final token = await _getToken();
      if (token == null) {
        emit(FavoriteError('No estás autenticado'));
        return;
      }

      await removeFromFavoritesUseCase(event.propertyId, token);
      
      // Actualizar el estado local SIEMPRE
      if (state is FavoriteLoaded) {
        final currentState = state as FavoriteLoaded;
        final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[event.propertyId] = false;
        
        // Remover de la lista de favoritos si estamos mostrando la lista
        final updatedFavorites = currentState.favorites
            .where((property) => property.id != event.propertyId)
            .toList();
        
        emit(currentState.copyWith(
          favorites: updatedFavorites,
          favoriteStatus: updatedStatus,
        ));
      } else {
        // Si no hay estado cargado, crear uno nuevo
        emit(FavoriteLoaded(
          favorites: [],
          favoriteStatus: {event.propertyId: false},
        ));
      }
      
      debugPrint('🔥 Favorito removido exitosamente');
    } catch (e) {
      debugPrint('🔥 Error al remover favorito: $e');
      emit(FavoriteError('Error al remover de favoritos: ${e.toString()}'));
    }
  }

  Future<void> _onCheckFavoriteStatus(CheckFavoriteStatus event, Emitter<FavoriteState> emit) async {
    try {
      final token = await _getToken();
      if (token == null) {
        if (state is FavoriteLoaded) {
          final currentState = state as FavoriteLoaded;
          final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
          updatedStatus[event.propertyId] = false;
          emit(currentState.copyWith(favoriteStatus: updatedStatus));
        }
        return;
      }

      final isFavorite = await checkIsFavoriteUseCase(event.propertyId, token);
      
      if (state is FavoriteLoaded) {
        final currentState = state as FavoriteLoaded;
        final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[event.propertyId] = isFavorite;
        emit(currentState.copyWith(favoriteStatus: updatedStatus));
      } else {
        emit(FavoriteLoaded(
          favorites: [],
          favoriteStatus: {event.propertyId: isFavorite},
        ));
      }
    } catch (e) {
      // Si hay error, asumir que no es favorito
      if (state is FavoriteLoaded) {
        final currentState = state as FavoriteLoaded;
        final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[event.propertyId] = false;
        emit(currentState.copyWith(favoriteStatus: updatedStatus));
      }
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoriteState> emit) async {
    debugPrint('🔥 ToggleFavorite - PropertyId: ${event.propertyId}, IsCurrentlyFavorite: ${event.isCurrentlyFavorite}');
    
    if (event.isCurrentlyFavorite) {
      debugPrint('🔥 Removiendo de favoritos...');
      add(RemoveFromFavorites(event.propertyId));
    } else {
      debugPrint('🔥 Agregando a favoritos...');
      add(AddToFavorites(event.propertyId));
    }
  }

  void _onClearFavorites(ClearFavorites event, Emitter<FavoriteState> emit) {
    emit(FavoriteLoaded(favorites: [], favoriteStatus: {}));
  }
  
  Future<void> _onLoadFavoriteStatus(LoadFavoriteStatus event, Emitter<FavoriteState> emit) async {
    try {
      final token = await _getToken();
      if (token == null) {
        if (state is FavoriteLoaded) {
          final currentState = state as FavoriteLoaded;
          final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
          for (final propertyId in event.propertyIds) {
            updatedStatus[propertyId] = false;
          }
          emit(currentState.copyWith(favoriteStatus: updatedStatus));
        } else {
          final Map<String, bool> favoriteStatus = {};
          for (final propertyId in event.propertyIds) {
            favoriteStatus[propertyId] = false;
          }
          emit(FavoriteLoaded(favorites: [], favoriteStatus: favoriteStatus));
        }
        return;
      }

      // Verificar el estado de cada propiedad
      final Map<String, bool> newFavoriteStatus = {};
      for (final propertyId in event.propertyIds) {
        try {
          final isFavorite = await checkIsFavoriteUseCase(propertyId, token);
          newFavoriteStatus[propertyId] = isFavorite;
        } catch (e) {
          newFavoriteStatus[propertyId] = false;
        }
      }
      
      if (state is FavoriteLoaded) {
        final currentState = state as FavoriteLoaded;
        final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus.addAll(newFavoriteStatus);
        emit(currentState.copyWith(favoriteStatus: updatedStatus));
      } else {
        emit(FavoriteLoaded(favorites: [], favoriteStatus: newFavoriteStatus));
      }
    } catch (e) {
      debugPrint('🔥 Error al cargar estado de favoritos: $e');
      // En caso de error, marcar todos como no favoritos
      if (state is FavoriteLoaded) {
        final currentState = state as FavoriteLoaded;
        final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
        for (final propertyId in event.propertyIds) {
          updatedStatus[propertyId] = false;
        }
        emit(currentState.copyWith(favoriteStatus: updatedStatus));
      }
    }
  }
} 
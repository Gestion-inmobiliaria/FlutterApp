import 'package:flutter_bloc/flutter_bloc.dart';
import 'realstate_event.dart';
import 'realstate_state.dart';
import 'package:inmobiliaria_app/data/sources/realstate_remote_datasource.dart';
import 'package:inmobiliaria_app/domain/entities/realstate_entity.dart';

class RealStateBloc extends Bloc<RealStateEvent, RealStateState> {
  final RealStateRemoteDatasource datasource;
  List<RealState> _allRealStates = [];

  RealStateBloc(this.datasource) : super(RealStateInitial()) {
    on<LoadRealStates>(_onLoadRealStates);
    on<SearchRealStates>(_onSearchRealStates); // <- nuevo evento
  }

  Future<void> _onLoadRealStates(
    LoadRealStates event,
    Emitter<RealStateState> emit,
  ) async {
    emit(RealStateLoading());

    try {
      final List<RealState> realStates = await datasource.fetchRealStates();
      _allRealStates = realStates; // Guardamos la lista original
      emit(RealStateLoaded(realStates));
    } catch (e) {
      emit(RealStateError('Error al cargar inmobiliarias'));
    }
  }

  void _onSearchRealStates(
    SearchRealStates event,
    Emitter<RealStateState> emit,
  ) {
    final query = event.query.toLowerCase();

    final filtered =
        _allRealStates
            .where((r) => r.name.toLowerCase().contains(query))
            .toList();

    emit(RealStateLoaded(filtered));
  }
}

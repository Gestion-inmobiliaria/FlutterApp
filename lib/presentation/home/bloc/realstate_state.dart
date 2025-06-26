import 'package:inmobiliaria_app/domain/entities/realstate_entity.dart';

abstract class RealStateState {}

class RealStateInitial extends RealStateState {}

class RealStateLoading extends RealStateState {}

class RealStateLoaded extends RealStateState {
  final List<RealState> realStates;
  RealStateLoaded(this.realStates);
}

class RealStateError extends RealStateState {
  final String message;
  RealStateError(this.message);
}

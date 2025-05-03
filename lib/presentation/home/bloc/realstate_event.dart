abstract class RealStateEvent {}

class LoadRealStates extends RealStateEvent {}

class SearchRealStates extends RealStateEvent {
  final String query;
  SearchRealStates(this.query);
}

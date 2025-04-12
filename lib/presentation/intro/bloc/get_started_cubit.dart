import 'package:flutter_bloc/flutter_bloc.dart';
import 'get_started_state.dart';

class GetStartedCubit extends Cubit<GetStartedState> {
  GetStartedCubit() : super(GetStartedInitial());

  void goToLogin() => emit(NavigateToLogin());

  void navigateToRegister() => emit(NavigateToRegister());
}

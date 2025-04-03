import 'package:flutter_bloc/flutter_bloc.dart';
import 'get_started_state.dart';

class GetStartedCubit extends Cubit<GetStartedState> {
  GetStartedCubit() : super(GetStartedInitial());

  void navigateToLogin() {
    print('[GetStartedCubit] Botón INICIAR SESIÓN presionado');
    //emit(NavigateToLogin());
  }

  void navigateToRegister() {
    print('[GetStartedCubit] Botón REGISTRARSE presionado');
    //emit(NavigateToRegister());
  }
}

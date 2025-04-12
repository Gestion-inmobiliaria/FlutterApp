import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/usecases/login_user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;

  AuthBloc(this.loginUser) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await loginUser(event.email, event.password);
        emit(AuthSuccess(token));
      } catch (e) {
        emit(AuthFailure('Credenciales inválidas o error de red'));
      }
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/usecases/login_user.dart';
import 'package:inmobiliaria_app/domain/usecases/register_user_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUserUseCase registerUser;

  AuthBloc(this.loginUser, this.registerUser) : super(AuthInitial()) {
    // login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await loginUser(event.email, event.password);
        emit(AuthSuccess(token));
      } catch (e) {
        emit(AuthFailure('Credenciales inválidas o error de red'));
      }
    });

    // registro
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        // 1. Registrar el usuario
        await registerUser(event.user);

        // 2. Hacer login automático
        final token = await loginUser(event.user.email, event.user.password);

        // 3. Emitir éxito
        emit(AuthSuccess(token));
      } catch (e) {
        String msg = e.toString();
        if (msg.contains('CI')) {
          emit(AuthFailure('El CI ya está registrado'));
        } else if (msg.contains('correo')) {
          emit(AuthFailure('El correo ya está registrado'));
        } else {
          emit(AuthFailure('Error al registrarse'));
        }
      }
    });
  }
}

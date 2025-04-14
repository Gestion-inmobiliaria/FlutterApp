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
        await registerUser(event.user);
        final token = await loginUser(event.user.email, event.user.password);
        emit(AuthSuccess(token));
      } catch (e) {
        // Intentamos obtener mensaje claro
        String errorMsg = 'Error al registrarse';

        try {
          // Intentamos extraer desde la respuesta
          final errorString = e.toString();

          if (errorString.contains('ci')) {
            errorMsg = 'El CI ya está registrado';
          } else if (errorString.contains('correo')) {
            errorMsg = 'El correo electrónico ya está registrado';
          } else if (errorString.contains('already exists')) {
            errorMsg = 'Este dato ya existe en la base de datos';
          } else {
            errorMsg = errorString;
          }
        } catch (_) {
          errorMsg = 'Error desconocido al registrarse';
        }

        emit(AuthFailure(errorMsg));
      }
    });
  }
}

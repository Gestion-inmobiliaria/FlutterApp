import 'package:equatable/equatable.dart';
import 'package:inmobiliaria_app/domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final UserEntity user;

  const SignUpRequested(this.user);

  @override
  List<Object> get props => [user];
}

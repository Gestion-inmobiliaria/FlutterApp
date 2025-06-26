import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inmobiliaria_app/domain/entities/user_entity.dart';

class AuthNotifier extends StateNotifier<UserEntity?> {
  AuthNotifier() : super(null);

  void setUser(UserEntity user) {
    state = user;
  }

  void logout() {
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserEntity?>((ref) {
  return AuthNotifier();
});

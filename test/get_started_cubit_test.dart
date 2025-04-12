import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:inmobiliaria_app/presentation/intro/bloc/get_started_cubit.dart';
import 'package:inmobiliaria_app/presentation/intro/bloc/get_started_state.dart';

void main() {
  group('GetStartedCubit', () {
    late GetStartedCubit cubit;

    setUp(() {
      cubit = GetStartedCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('estado inicial debe ser GetStartedInitial', () {
      expect(cubit.state, isA<GetStartedInitial>());
    });

    blocTest<GetStartedCubit, GetStartedState>(
      'emite NavigateToLogin cuando se llama goToLogin',
      build: () => GetStartedCubit(),
      act: (cubit) => cubit.goToLogin(),
      expect: () => [isA<NavigateToLogin>()],
    );

    blocTest<GetStartedCubit, GetStartedState>(
      'emite NavigateToRegister cuando se llama navigateToRegister',
      build: () => GetStartedCubit(),
      act: (cubit) => cubit.navigateToRegister(),
      expect: () => [isA<NavigateToRegister>()],
    );
  });
}

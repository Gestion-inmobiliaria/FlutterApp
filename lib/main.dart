import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:inmobiliaria_app/core/configs/theme/app_theme.dart';
import 'package:inmobiliaria_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_bloc.dart';
import 'package:inmobiliaria_app/data/sources/realstate_remote_datasource.dart';
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_event.dart';
import 'package:inmobiliaria_app/presentation/splash/pages/splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inmobiliaria_app/domain/providers/auth_provider.dart';
import 'package:inmobiliaria_app/data/sources/auth_remote_datasource_impl.dart';

import 'service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error cargando .env: $e");
    try {
      await dotenv.load(fileName: ".envExample");
    } catch (e) {
      debugPrint("Error cargando .envExample: $e");
    }
  }

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await Stripe.instance.applySettings();

  final container = ProviderContainer();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token != null) {
    final user = await AuthRemoteDataSourceImpl(
      client: http.Client(),
    ).getUserFromToken(token);
    if (user != null) {
      container.read(authProvider.notifier).setUser(user);
    }
  }

  setupLocator();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
          BlocProvider<RealStateBloc>(
            create:
                (_) =>
                    RealStateBloc(RealStateRemoteDatasource())
                      ..add(LoadRealStates()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightheme,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}

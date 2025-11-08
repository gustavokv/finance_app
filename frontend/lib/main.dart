import 'package:flutter/material.dart';

import 'package:finance_app/services/api_service.dart';
import 'package:finance_app/services/secure_storage_service.dart';
import 'package:finance_app/screens/auth_screen.dart';
import 'package:finance_app/screens/home_screen.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

void main() async {
  // Garantees that the Flutter bindings were initialized
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService.instance;
  final apiService = ApiService.instance;

  final String? authToken = await storage.getAuthToken();

  if (authToken != null) {
    apiService.setAuthToken(authToken);
  }

  runApp(FinanceApp(isLoggedIn: authToken != null));
}

class FinanceApp extends StatelessWidget {
  FinanceApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',
      routerConfig: _router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }

  late final GoRouter _router = GoRouter(
    redirect: (context, state) {
      if (isLoggedIn) {
        return '/home';
      } else {
        return '/';
      }
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Login(),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const Home()),
        ],
      ),
    ],
  );
}

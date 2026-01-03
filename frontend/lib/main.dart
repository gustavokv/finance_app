import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:finance_app/services/api_service.dart';
import 'package:finance_app/services/secure_storage_service.dart';
import 'package:finance_app/screens/auth_screen.dart';
import 'package:finance_app/screens/home_screen.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/utils/util_snackbar.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  final storage = SecureStorageService.instance;
  final apiService = ApiService.instance;

  String? accessToken;

  try {
    final dynamic response = await apiService.post('/auth/access-token');

    if (response.statusCode == 200) {
      accessToken = response.data['token'];
      final user = response.data['user'];

      if (accessToken != null) {
        await storage.saveAuthToken(accessToken, 'accessToken');
        await storage.saveUser(user);
        apiService.setAuthToken(accessToken);
      }
    }
  } catch (error) {
    accessToken = null;
    print('Erro na verificação inicial de token: $error');
  }

  runApp(FinanceApp(initialRoute: accessToken != null ? '/home' : '/'));
}

class FinanceApp extends StatelessWidget {
  final String initialRoute;

  const FinanceApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Login()),
        GoRoute(path: '/home', builder: (context, state) => const Home()),
      ],
    );

    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,

      debugShowCheckedModeBanner: false,
      title: 'Finance App',
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}

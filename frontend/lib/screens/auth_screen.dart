import 'package:flutter/material.dart';

import 'package:finance_app/services/api_service.dart';
import 'package:finance_app/services/secure_storage_service.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isAuthenticating = false;
  bool _isLogin = true;
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            padding: EdgeInsets.only(
              top: screenHeight * (_isAuthenticating ? 0.06 : 0.15),
            ),
            child: Column(
              children: [
                // Animated opacity for icon and subtitle
                if (!_isAuthenticating)
                  AnimatedOpacity(
                    opacity: _isAuthenticating ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.attach_money,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 80,
                    ),
                  ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'FinanceApp',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _isAuthenticating ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    'O aplicativo pessoal de finanças da minha princesa',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Animated Card
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutQuad,
              // Card height changes from 80% to 50% on screen
              height: screenHeight * (_isAuthenticating ? 0.80 : 0.5),
              width: double.infinity,
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(70.0),
                  ),
                ),
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.onSurface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 50,
                  ),
                  // AnimatedSwitcher to animate the content change
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _isAuthenticating
                        ? _isLogin
                              ? _buildLoginForm()
                              : _buildRegisterForm()
                        : _buildAuthButtons(screenWidth), // Initial buttons
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Login and Register buttons
  Widget _buildAuthButtons(double screenWidth) {
    return Column(
      key: const ValueKey('authButtons'), // Key to the AnimatedSwitcher
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Bem Vindo(a)',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Faça Log-In ou Registre-se para gerenciar suas finanças da melhor forma.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 40),
          child: Column(
            spacing: 12,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 10,
                children: [
                  authButtonTemplate(_toggleAuth, 'Login', screenWidth * 0.35),
                  authButtonTemplate(
                    _toggleAuthRegister,
                    'Registre-se',
                    screenWidth * 0.35,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              IconButton(
                onPressed: () {},
                icon: Image.asset('assets/images/google_logo.png', scale: 4),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('authForm'), // Key to the AnimatedSwitcher
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _toggleAuth, // Button to reverse the animation
            ),
            Text(
              'Login',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Form(
          key: loginFormKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 40),
              authButtonTemplate(_loginUser, 'Entrar', double.infinity),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('authForm'), // Key to the AnimatedSwitcher
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _toggleAuth, // Button to reverse the animation
            ),
            Text(
              'Registre-se',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Form(
          key: registerFormKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordConfirmationController,
                decoration: const InputDecoration(labelText: 'Repita a Senha'),
                obscureText: true,
                validator: (context) {
                  if (_passwordConfirmationController.text == '') {
                    return 'Digite sua senha novamente';
                  }

                  if (_passwordController.text !=
                      _passwordConfirmationController.text) {
                    return 'As senhas devem ser iguais';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 40),
              authButtonTemplate(_registerUser, 'Entrar', double.infinity),
            ],
          ),
        ),
      ],
    );
  }

  /// Changes the authentication state to trigger between animations
  void _toggleAuth() {
    setState(() {
      _isLogin = true;
      _isAuthenticating = !_isAuthenticating;
    });
  }

  void _toggleAuthRegister() {
    setState(() {
      _isLogin = false;
      _isAuthenticating = !_isAuthenticating;
    });
  }

  void _loginUser() async {
    try {
      final response = await ApiService.instance.post(
        '/login',
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final username = response.data['username'];

        final storage = SecureStorageService.instance;
        await storage.saveAuthToken(token);
        await storage.saveUsername(username);
        ApiService.instance.setAuthToken(token);

        if (!mounted) return;
        context.go('/home');
      }
    } catch (e) {
      print('Fail on login: $e');
    }
  }

  void _registerUser() async {
    try {
      final response = await ApiService.instance.post(
        '/register',
        data: {
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];

        final storage = SecureStorageService.instance;
        await storage.saveAuthToken(token);
        await storage.saveUsername(_usernameController.text);
        ApiService.instance.setAuthToken(token);

        if (!mounted) return;
        context.go('/home');
      }
    } catch (e) {
      print('Fail on register: $e');
    }
  }

  ElevatedButton authButtonTemplate(
    void Function() action,
    text,
    width, {
    height = 40.0,
  }) {
    return ElevatedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

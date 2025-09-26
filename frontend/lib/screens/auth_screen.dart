import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isAuthenticating = false;
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background animado
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            // O padding superior diminui para o título "subir"
            padding: EdgeInsets.only(
              top: screenHeight * (_isAuthenticating ? 0.06 : 0.15),
            ),
            child: Column(
              children: [
                // Opacidade animada para o ícone e subtítulo
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

          // Card animado
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutQuad,
              // A altura do card muda de 50% para 80% da tela
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
                  // AnimatedSwitcher para animar a troca de conteúdo
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _isAuthenticating
                        ? _isLogin
                              ? _buildLoginForm()
                              : _buildRegisterForm() // Formulário de Login/Registro
                        : _buildAuthButtons(screenWidth), // Botões Iniciais
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói os botões de "Log-In" e "Registre-se"
  Widget _buildAuthButtons(double screenWidth) {
    return Column(
      key: const ValueKey('authButtons'), // Chave para o AnimatedSwitcher
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
      key: const ValueKey('authForm'), // Chave para o AnimatedSwitcher
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _toggleAuth, // Botão para reverter a animação
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
        const SizedBox(height: 30),
        TextFormField(decoration: const InputDecoration(labelText: 'Email')),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Senha'),
          obscureText: true,
        ),
        const SizedBox(height: 40),
        authButtonTemplate(() async {}, 'Entrar', double.infinity),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('authForm'), // Chave para o AnimatedSwitcher
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _toggleAuth, // Botão para reverter a animação
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
        const SizedBox(height: 30),
        TextFormField(decoration: const InputDecoration(labelText: 'Email')),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Senha'),
          obscureText: true,
        ),
        const SizedBox(height: 40),
        authButtonTemplate(() async {}, 'Entrar', double.infinity),
      ],
    );
  }

  /// Alterna o estado de autenticação para disparar as animações
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

import 'package:dio/dio.dart';
import 'package:finance_app/utils/util_snackbar.dart';
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
  // Estado da Animação e Fluxo
  bool _isAuthenticating = false;
  bool _isLogin = true;

  // Controle de visibilidade de senha
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Keys e Controllers
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Cores baseadas no tema
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double cardHeight;
    if (!_isAuthenticating) {
      cardHeight = screenHeight * 0.42; // Tela inicial
    } else if (_isLogin) {
      cardHeight = screenHeight * 0.58; // Login (apenas 2 campos)
    } else {
      cardHeight = screenHeight * 0.88; // Registro (4 campos + botão)
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que o teclado quebre o layout
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: screenHeight * (_isAuthenticating ? 0.04 : 0.12),
            left: 0,
            right: 0,
            child: Column(
              children: [
                AnimatedOpacity(
                  opacity: _isAuthenticating ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
                SizedBox(height: _isAuthenticating ? 10 : 20),
                const Text(
                  'FinanceApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                if (!_isAuthenticating) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'O aplicativo pessoal de finanças da minha princesa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutQuint,
            bottom: 0,
            left: 0,
            right: 0,
            height: cardHeight,
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _isAuthenticating
                        ? (_isLogin ? _buildLoginForm() : _buildRegisterForm())
                        : _buildAuthButtons(screenWidth, primaryColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildAuthButtons(double screenWidth, Color primaryColor) {
    return Column(
      key: const ValueKey('authButtons'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem Vinda',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gerencie suas finanças com elegância.',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: _ModernButton(
                text: "Login",
                onPressed: _toggleAuth,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _ModernButton(
                text: "Registrar",
                onPressed: _toggleAuthRegister,
                isPrimary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('loginForm'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader("Login", _toggleAuth),
        const SizedBox(height: 25),
        Form(
          key: loginFormKey,
          child: Column(
            children: [
              _ModernInput(
                controller: _emailController,
                label: "E-mail",
                placeholder: "exemplo@email.com",
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite seu e-mail';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _ModernInput(
                controller: _passwordController,
                label: "Senha",
                placeholder: "Sua senha segura",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Digite sua senha';
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text("Esqueceu a senha?"),
                ),
              ),
              const SizedBox(height: 20),
              _ModernButton(
                text: "ENTRAR",
                onPressed: _loginUser,
                isPrimary: true,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('registerForm'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader("Criar Conta", _toggleAuthRegister),
        const SizedBox(height: 20),
        Form(
          key: registerFormKey,
          child: Column(
            children: [
              _ModernInput(
                controller: _usernameController,
                label: "Nome Completo",
                placeholder: "Seu nome",
                icon: Icons.person_outline_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Insira seu nome' : null,
              ),
              const SizedBox(height: 12),
              _ModernInput(
                controller: _emailController,
                label: "E-mail",
                placeholder: "exemplo@email.com",
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira um e-mail';
                  if (!value.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _ModernInput(
                controller: _passwordController,
                label: "Senha",
                placeholder: "Mínimo 8 caracteres",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira uma senha';
                  if (value.length < 8) {
                    return 'Min. 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _ModernInput(
                controller: _passwordConfirmationController,
                label: "Confirmar Senha",
                placeholder: "Repita a senha",
                icon: Icons.check_circle_outline_rounded,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Repita a senha';
                  if (_passwordController.text != value) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              _ModernButton(
                text: "CADASTRAR",
                onPressed: _registerUser,
                isPrimary: true,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, VoidCallback onBack) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // --- LÓGICA DE NEGÓCIO ---

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
    if (loginFormKey.currentState?.validate() != true) return;

    try {
      final response = await ApiService.instance.post(
        '/auth/login',
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        final user = response.data['user'];
        await SecureStorageService.instance.saveAuthToken(token, 'accessToken');
        await SecureStorageService.instance.saveUser(user);
        ApiService.instance.setAuthToken(token);

        if (!mounted) return;
        context.go('/home');
      } else {
        if (!mounted) return;
        UtilSnackBar.showError(response.data['message'] ?? 'Falha no login');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      UtilSnackBar.showError(e.response?.data['message'] ?? 'Erro de conexão.');
    }
  }

  void _registerUser() async {
    if (registerFormKey.currentState?.validate() != true) return;

    try {
      final response = await ApiService.instance.post(
        '/auth/register',
        data: {
          'name': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        UtilSnackBar.showSuccess('Conta criada! Faça login.');
        _toggleAuth();
      } else {
        if (!mounted) return;
        UtilSnackBar.showError(
          response.data['message'] ?? 'Falha ao registrar.',
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      UtilSnackBar.showError(
        e.response?.data['message'] ?? 'Erro de servidor.',
      );
    }
  }
}

class _ModernInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _ModernInput({
    required this.controller,
    required this.label,
    required this.placeholder,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool fullWidth;

  const _ModernButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          foregroundColor: isPrimary
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
          elevation: isPrimary ? 6 : 0,
          shadowColor: isPrimary
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
          ),
        ),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

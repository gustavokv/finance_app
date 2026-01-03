import 'package:flutter/material.dart';

/// Chave Global para controlar SnackBars de qualquer lugar do app
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class UtilSnackBar {
  static void _show({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    // Usa a chave global em vez do context
    final messenger = rootScaffoldMessengerKey.currentState;

    if (messenger == null) {
      debugPrint(
        '❌ ERRO UtilSnackBar: ScaffoldMessenger é null. Você esqueceu de adicionar "scaffoldMessengerKey: rootScaffoldMessengerKey" no MaterialApp do main.dart?',
      );
      return;
    }

    // Remove qualquer snackbar anterior imediatamente para evitar empilhamento
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        // Define a duração para 5 segundos
        duration: const Duration(seconds: 5),
        // Usar showCloseIcon (nativo do Material 3) é mais robusto para o timer
        // do que usar uma 'action' customizada, que pode prolongar a exibição
        // dependendo das configurações de acessibilidade.
        showCloseIcon: true,
        closeIconColor: Colors.white,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  // --- Métodos Públicos (Não precisam mais de context!) ---

  static void showSuccess(String message) {
    _show(
      message: message,
      color: Colors.green.shade700,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showError(String message) {
    _show(
      message: message,
      color: Colors.red.shade700,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showWarning(String message) {
    _show(
      message: message,
      color: Colors.orange.shade800,
      icon: Icons.warning_amber_rounded,
    );
  }
}

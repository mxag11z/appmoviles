import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appmoviles/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  final authService = AuthService();
  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    final email = emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ingresa tu correo.")));
      return;
    }

    setState(() => isLoading = true);

    final error = await authService.sendPasswordResetEmail(email);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $error")));
      return;
    }

    // Diálogo explicando lo del token
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Correo enviado"),
        content: const Text(
          "Te enviamos un correo para restablecer tu contraseña.\n\n"
          "En el correo verás un TOKEN (código). "
          "Cópialo y en la siguiente pantalla pégalo junto con tu nueva contraseña.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Continuar"),
          ),
        ],
      ),
    );

    // Ir a la pantalla del formulario con token
    context.go('/reset-password-form?email=$email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text("Olvidé mi contraseña"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recuperar contraseña",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Ingresa el correo con el que te registraste. "
              "Te enviaremos un correo con un token de recuperación.",
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Correo",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _handleSendReset,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Enviar correo"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

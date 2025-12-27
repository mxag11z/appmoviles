import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appmoviles/services/auth_service.dart';

class ResetPasswordWithTokenScreen extends StatefulWidget {
  final String email;
  const ResetPasswordWithTokenScreen({super.key, required this.email});

  @override
  State<ResetPasswordWithTokenScreen> createState() =>
      _ResetPasswordWithTokenScreenState();
}

class _ResetPasswordWithTokenScreenState
    extends State<ResetPasswordWithTokenScreen> {
  final tokenCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final authService = AuthService();
  bool isLoading = false;

  @override
  void dispose() {
    tokenCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final token = tokenCtrl.text.trim();
    final password = passCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    if (token.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos.")),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final error = await authService.resetPasswordWithToken(
      email: widget.email,
      token: token,
      newPassword: password,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Contraseña actualizada correctamente.")),
    );

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restablecer contraseña")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Correo: ${widget.email}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Pega el token de recuperación que aparece en el correo:",
            ),
            const SizedBox(height: 8),
            TextField(
              controller: tokenCtrl,
              decoration: const InputDecoration(
                labelText: "Token de recuperación",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nueva contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmar contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _handleReset,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Actualizar contraseña"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

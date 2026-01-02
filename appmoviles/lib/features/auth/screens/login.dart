import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _supabase = Supabase.instance.client;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? error;
  bool isLoading = false;

  final ipnRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@alumno\.ipn\.mx$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Text("Bienvenido",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {},
                    child: const Text("Iniciar Sesión"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go("/register"),
                    child: const Text("Registrarse"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email Institucional",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),

            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text("¿Olvidaste tu contraseña?"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Iniciar Sesión", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (!ipnRegex.hasMatch(email)) {
      setState(() => error = "El correo debe ser @alumno.ipn.mx");
      return;
    }

    if (password.isEmpty) {
      setState(() => error = "La contraseña no puede estar vacía");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw 'Error al iniciar sesión';
      }

      debugPrint('✅ Login exitoso: ${authResponse.user!.email}');

      if (mounted) {
        context.go("/admin/home");
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = "Credenciales incorrectas o error de conexión");
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}

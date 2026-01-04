import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:appmoviles/services/auth_service.dart';
import 'package:appmoviles/services/user_service.dart';
import 'package:appmoviles/providers/notification_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final authService = AuthService();
  final userService = UserService();

  final _supabase = Supabase.instance.client;

  String? error;
  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Llena tu correo y contraseña.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final error = await authService.loginUser(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    // Login OK → leer el usuario y su rol
    final usuario = await userService.getCurrentUsuario();

    if (!mounted) return;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró el perfil de usuario.")),
      );
      return;
    }

    // Inicializar notificaciones push
    ref.read(notificationProvider.notifier).initialize();

    String targetRoute = '/estudiante/home';
    if (usuario.rol == 2) {
      targetRoute = '/organizador/home';
    } else if (usuario.rol == 3) {
      targetRoute = '/admin/home';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Inicio de sesión exitoso.")),
    );

    context.go(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Iniciar sesión"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenido",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: emailCtrl,
              decoration:
                  const InputDecoration(labelText: "Correo institucional"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contraseña"),
            ),

            const SizedBox(height: 30),

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
                    : const Text(
                        "Iniciar sesión",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () => context.push('/register'),
                child: const Text("¿No tienes cuenta? Regístrate"),
              ),
            ),

            Center(
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text("Olvidé mi contraseña"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}

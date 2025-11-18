import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? error;

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
                onPressed: () {
                  final email = emailCtrl.text.trim();
                  if (!ipnRegex.hasMatch(email)) {
                    setState(() => error = "El correo debe ser @alumno.ipn.mx");
                    return;
                  }

                  setState(() => error = null);

                  // TODO: login con Supabase
                },
                child: const Text("Iniciar Sesión", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

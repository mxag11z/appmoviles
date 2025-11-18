import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  String selectedRole = "estudiante";
  List<String> selectedInterests = [];
  final ipnRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@alumno\.ipn\.mx$');

  List<String> intereses = [
    "Tecnología", "Arte", "Deportes",
    "Música", "Ciencia", "Cine"
  ];

  @override
  Widget build(BuildContext context) {
    //verificacion de que la contraseña sea la misma, es decir que se confirme
    bool passwordMismatch = passCtrl.text != confirmCtrl.text;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), //regresar al login
          onPressed: () => context.go("/login"),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Crear Cuenta",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 20),

            Center(
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey.shade200,
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 34),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre Completo",
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email Institucional",
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirmar Contraseña",
                errorText: passwordMismatch ? "Las contraseñas no coinciden." : null,
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),
            const Text("¿Cuál es tu rol?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: selectedRole == "estudiante"
                          ? Colors.blue
                          : Colors.grey.shade200,
                      foregroundColor: selectedRole == "estudiante"
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () {
                      setState(() => selectedRole = "estudiante");
                    },
                    child: const Text("Estudiante"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: selectedRole == "organizador"
                          ? Colors.blue
                          : Colors.grey.shade200,
                      foregroundColor: selectedRole == "organizador"
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () {
                      setState(() => selectedRole = "organizador");
                    },
                    child: const Text("Organizador"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Selecciona tus intereses",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            Wrap(
              spacing: 6,
              children: intereses.map((i) {
                final isSelected = selectedInterests.contains(i);

                return FilterChip(
                  label: Text(i),
                  selected: isSelected,
                  onSelected: (bool value) {
                    setState(() {
                      if (value) {
                        selectedInterests.add(i);
                      } else {
                        selectedInterests.remove(i);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (!ipnRegex.hasMatch(emailCtrl.text.trim())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("El correo debe ser @alumno.ipn.mx"),
                      ),
                    );
                    return;
                  }

                  if (passwordMismatch) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Las contraseñas no coinciden."),
                      ),
                    );
                    return;
                  }

                  // TODO: registrarse en Supabase

                },
                child: const Text("Registrarse", style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                "Al registrarte, aceptas nuestros Términos y Condiciones.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          ],
        ),
      ),
    );
  }
}

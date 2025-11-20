import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appmoviles/services/auth_service.dart';
import 'package:appmoviles/services/storage_service.dart';
import 'package:appmoviles/services/user_service.dart';
import 'package:appmoviles/core/widgets/profile_image_picker.dart';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final apellidoPaternoCtrl = TextEditingController();
  final apellidoMaternoCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  File? selectedImage;
  final storageService = StorageService();
  final userService = UserService();
  final authService = AuthService();

  int selectedRole = 1;
  List<String> selectedInterests = [];
  final ipnRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@alumno\.ipn\.mx$');

  List<String> intereses = [
    "Tecnología",
    "Arte",
    "Deportes",
    "Música",
    "Ciencia",
    "Cine",
  ];

  @override
  Widget build(BuildContext context) {
    //verificacion de que la contraseña sea la misma, es decir que se confirme
    bool passwordMismatch = passCtrl.text != confirmCtrl.text;

    return Scaffold(
      //pantalla completa scaffold
      appBar: AppBar(
        //barra superior
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          //lo que va a la izquierda
          icon: const Icon(Icons.arrow_back), //regresar al login
          onPressed: () => context.go("/login"),
        ),
      ),

      //para el body del scaffold usamos una singleScrollview para poder
      //deslizar el contenido
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Crear Cuenta",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Center(
              child: ProfileImagePicker(
                imageFile: selectedImage,
                onPickImage: () async {
                  final img = await storageService.pickImage();
                  if (img != null) {
                    setState(() => selectedImage = img);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: apellidoPaternoCtrl,
              decoration: const InputDecoration(labelText: "Apellido Paterno"),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: apellidoMaternoCtrl,
              decoration: const InputDecoration(labelText: "Apellido Materno"),
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
              decoration: const InputDecoration(labelText: "Contraseña"),
              onChanged: (_) => setState(
                () {},
              ), //para reconstruir el UI en cada cambio de tecla
            ),

            const SizedBox(height: 14),

            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirmar Contraseña",
                errorText: passwordMismatch
                    ? "Las contraseñas no coinciden."
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),
            const Text(
              "¿Cuál es tu rol?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: selectedRole == 1
                          ? Colors.blue
                          : Colors.grey.shade200,
                      foregroundColor: selectedRole == 1
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () {
                      setState(() => selectedRole = 1);
                    },
                    child: const Text("Estudiante"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: selectedRole == 2
                          ? Colors.blue
                          : Colors.grey.shade200,
                      foregroundColor: selectedRole == 2
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () {
                      setState(() => selectedRole = 2);
                    },
                    child: const Text("Organizador"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Selecciona tus intereses",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

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
                onPressed: () async {
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

                  final auth = AuthService(); //mandamos llamar al servicio

                  final error = await authService.registerUser(
                    nombre: nameCtrl.text.trim(),
                    apellidoPaterno: apellidoPaternoCtrl.text.trim(),
                    apellidoMaterno: apellidoMaternoCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text.trim(),
                    rol: selectedRole, // id rol en tabla roles
                    intereses: selectedRole == 1 ? selectedInterests : [],
                    fotoFile: selectedImage, // se sube al bucket 
                  );

                  if (error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $error")));
                    return;
                  }

                  // Si todo salió bien
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Registro exitoso")),
                  );

                  // Redirigir al login
                  context.go('/login');
                },

                child: const Text(
                  "Registrarse",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                "Al registrarte, aceptas nuestros Términos y Condiciones.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

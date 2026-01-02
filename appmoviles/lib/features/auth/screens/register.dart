import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appmoviles/services/auth_service.dart';
import 'package:appmoviles/services/storage_service.dart';
import 'package:appmoviles/services/user_service.dart';
import 'dart:io';
import 'package:appmoviles/data/models/usuario_model.dart';
import 'package:appmoviles/data/models/student_model.dart';
import 'package:appmoviles/services/carreras_service.dart';
import 'package:appmoviles/data/models/carrera_model.dart';

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

  int selectedRole = 1; // 1, estudiante, 2, organizador
  List<String> selectedInterests = [];

  final ipnRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@alumno\.ipn\.mx$');

  // para estudiante
  int? selectedCareer; // id carrera
  int? selectedSemester; //

  List<String> intereses = [
    "Tecnología",
    "Arte",
    "Deportes",
    "Música",
    "Ciencia",
    "Cine",
  ];

  final carrerasService = CarrerasService();
  List<CarreraModel> carreras = [];
  bool loadingCarreras = true;
  String? carrerasError;

  @override
  void initState() {
    super.initState();
    _loadCarreras();
  }

  Future<void> _loadCarreras() async {
    setState(() {
      loadingCarreras = true;
      carrerasError = null;
    });

    try {
      final fetched = await carrerasService.fetchCarreras();
      print('fetchCarreras returned: $fetched');
      if (!mounted) return;
      setState(() {
        carreras = fetched ?? [];
        loadingCarreras = false;
      });
    } catch (e, st) {
      print('Error loading carreras: $e\n$st');
      if (!mounted) return;
      setState(() {
        carreras = [];
        loadingCarreras = false;
        carrerasError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando carreras: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool passwordMismatch = passCtrl.text != confirmCtrl.text;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
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
              onChanged: (_) => setState(() {}),
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
                      setState(() {
                        selectedRole = 1;
                      });
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
                      setState(() {
                        selectedRole = 2;
                        // if changes to organizer clear
                        selectedInterests.clear();
                        selectedCareer = null;
                        selectedSemester = null;
                      });
                    },
                    child: const Text("Organizador"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // fields estudiantes
            if (selectedRole == 1) ...[
              const Text(
                "Carrera",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (loadingCarreras)
                const Center(child: CircularProgressIndicator())
              else if (carrerasError != null)
                Text(
                  'Error cargando carreras: $carrerasError',
                  style: TextStyle(color: Colors.red),
                )
              else
                DropdownButtonFormField<int>(
                  value: selectedCareer,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Selecciona tu carrera",
                  ),
                  items: carreras
                      .map((c) {
                        final int? id = c.idCarrera; // or c.id
                        final String label = c.carrera;
                        if (id == null) return null;
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(label),
                        );
                      })
                      .whereType<DropdownMenuItem<int>>()
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCareer = value);
                  },
                ),

              const SizedBox(height: 16),

              const Text(
                "Semestre",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedSemester,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Selecciona tu semestre",
                ),
                items: List.generate(10, (index) => index + 1)
                    .map(
                      (s) => DropdownMenuItem<int>(value: s, child: Text("$s")),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedSemester = value);
                },
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
            ],

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  // TODO: Descomentar para producción
                  // if (!ipnRegex.hasMatch(emailCtrl.text.trim())) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text("El correo debe ser @alumno.ipn.mx"),
                  //     ),
                  //   );
                  //   return;
                  // }

                  if (passwordMismatch) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Las contraseñas no coinciden."),
                      ),
                    );
                    return;
                  }

                  // validaciones extra si es estudiante
                  if (selectedRole == 1) {
                    if (selectedCareer == null || selectedSemester == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Selecciona tu carrera y semestre, por favor.",
                          ),
                        ),
                      );
                      return;
                    }
                  }

                  final interesesUsuario = selectedRole == 1
                      ? selectedInterests
                      : <String>[];

                  // modelo Usuario
                  final nuevoUsuario = Usuario(
                    idUsuario: "",
                    nombre: nameCtrl.text.trim(),
                    apellidoPaterno: apellidoPaternoCtrl.text.trim(),
                    apellidoMaterno: apellidoMaternoCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    rol: selectedRole,
                    foto: null,
                  );

                  // modelo estudiante (solo si aplica)
                  StudentModel? studentModel;
                  if (selectedRole == 1) {
                    studentModel = StudentModel(
                      idUsuario: "",
                      carreraFK: selectedCareer!,
                      semestre: selectedSemester!,
                      intereses: interesesUsuario,
                    );
                  }

                  final error = await authService.registerUser(
                    usuario: nuevoUsuario,
                    password: passCtrl.text.trim(),
                    fotoFile: selectedImage,
                    estudiante: studentModel,
                  );

                  if (error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $error")));
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Registro exitoso. Te enviamos un correo para confirmar tu cuenta.",
                      ),
                      duration: Duration(seconds: 4),
                    ),
                  );

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

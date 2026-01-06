import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/evento_model.dart';
import '../services/event_service.dart';
import '../services/storage_service.dart';

class RegisterEventScreen extends StatefulWidget {
  const RegisterEventScreen({super.key});

  @override
  State<RegisterEventScreen> createState() => _RegisterEventScreenState();
}

class _RegisterEventScreenState extends State<RegisterEventScreen> {
  int cupo = 30;
  final _formKey = GlobalKey<FormState>();
  final crudEventService = CrudEventService();

  final tituloCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final ubicacionCtrl = TextEditingController();
  final cupoCtrl = TextEditingController();

  DateTime? fechaInicio;
  DateTime? fechaFin;

  int categoriaFk = 1; // default
  File? imagenEvento;
  String? extensionImagen;
  final storageService = StorageService();

  final picker = ImagePicker();

  /// categorías estáticas (id → nombre)
  final categorias = const {
    1: 'General',
    2: 'Tecnología',
    3: 'Arte',
    4: 'Deportes',
    5: 'Música',
    6: 'Ciencia',
  };

  Future<void> pickImage() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => imagenEvento = File(picked.path));
    }
  }

  Future<void> pickFecha(bool inicio) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    if (!mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final DateTime fechaHoraCompleta = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      inicio ? fechaInicio = fechaHoraCompleta : fechaFin = fechaHoraCompleta;
    });
  }

  /// Registrar evento
  Future<void> registrarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    if (fechaInicio == null || fechaFin == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecciona las fechas")));
      return;
    }

    if (imagenEvento == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecciona una imagen")));
      return;
    }

    try {
      final String? urlPublica = await storageService.uploadEventImage(
        imagenEvento!,
      );

      if (urlPublica == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al subir la imagen")),
        );
        return;
      }

      final evento = Evento(
        idEvento: '', // Supabase lo genera
        titulo: tituloCtrl.text.trim(),
        descripcion: descripcionCtrl.text.trim(),
        fechaInicio: fechaInicio!,
        fechaFin: fechaFin!,
        ubicacion: ubicacionCtrl.text.trim(),
        cupo: cupo,
        status: 'Pendiente',
        organizadorFK: Supabase.instance.client.auth.currentUser?.id ?? '',
        categoriaFk: categoriaFk,
        categoriaNombre: categorias[categoriaFk] ?? 'General',
        foto: urlPublica,
      );

      final error = await crudEventService.crearEvento(evento: evento);

      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error DB: $error")));
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento registrado correctamente')),
        );
        context.pop();
      }
    } catch (e) {
      print('Excepción: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ocurrio un error inesperado")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go("/organizador/home"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final XFile? picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );

                    if (picked != null) {
                      setState(() {
                        imagenEvento = File(picked.path);
                        // Capturamos la extensión del nombre del archivo
                        extensionImagen = picked.name.split('.').last;
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: imagenEvento != null
                        ? FileImage(imagenEvento!)
                        : null,
                    child: imagenEvento == null
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),

              TextFormField(
                controller: descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),

              DropdownButtonFormField<int>(
                value: categoriaFk,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categorias.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => categoriaFk = v!),
              ),

              TextFormField(
                controller: ubicacionCtrl,
                decoration: const InputDecoration(labelText: 'Ubicación'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cupo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: cupo > 1
                              ? () => setState(() => cupo--)
                              : null,
                        ),

                        Text(
                          '$cupo',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => cupo++),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => pickFecha(true),
                      child: Text(
                        fechaInicio == null
                            ? 'Fecha inicio'
                            : fechaInicio!.toLocal().toString().split(' ')[0],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => pickFecha(false),
                      child: Text(
                        fechaFin == null
                            ? 'Fecha fin'
                            : fechaFin!.toLocal().toString().split(' ')[0],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              FilledButton(
                onPressed: registrarEvento,
                child: const Text('Publicar evento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

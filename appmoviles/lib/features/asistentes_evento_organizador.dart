import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/asistentes_service.dart';
import '../data/models/asistente_evento_model.dart';

class AsistentesEventosScreen extends StatefulWidget {
  final String eventoId;

  const AsistentesEventosScreen({super.key, required this.eventoId});

  @override
  State<AsistentesEventosScreen> createState() =>
      _AsistentesEventosScreenState();
}

class _AsistentesEventosScreenState extends State<AsistentesEventosScreen> {
  final AsistentesService _service = AsistentesService();
  late Future<List<AsistenteEvento>> _asistentesFuture;

  @override
  void initState() {
    super.initState();
    _asistentesFuture = _service.obtenerAsistentesPorEvento(widget.eventoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistentes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go("/organizador/mis-eventos"),
        ),
      ),
      body: FutureBuilder<List<AsistenteEvento>>(
        future: _asistentesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final asistentes = snapshot.data ?? [];

          if (asistentes.isEmpty) {
            return const Center(child: Text('No hay asistentes registrados'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: asistentes.length,
            itemBuilder: (context, index) {
              final asistente = asistentes[index];

              return _AsistenteCard(asistente: asistente);
            },
          );
        },
      ),
    );
  }
}

class _AsistenteCard extends StatelessWidget {
  final AsistenteEvento asistente;

  const _AsistenteCard({required this.asistente});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// FOTO
          CircleAvatar(
            radius: 28,
            backgroundImage:
                (asistente.foto != null && asistente.foto!.isNotEmpty)
                ? NetworkImage(asistente.foto!)
                : null,
            child: (asistente.foto == null || asistente.foto!.isEmpty)
                ? const Icon(Icons.person, size: 30)
                : null,
          ),

          const SizedBox(width: 14),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asistente.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asistente.email,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

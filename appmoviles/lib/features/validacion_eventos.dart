import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../data/models/evento_model.dart';

class EventosContent extends StatefulWidget {
  const EventosContent({super.key});

  @override
  State<EventosContent> createState() => _EventosContentState();
}

class _EventosContentState extends State<EventosContent> {
  final EventService _eventService = EventService();
  late Future<List<Evento>> _eventosFuture;

  @override
  void initState() {
    super.initState();
    _eventosFuture = _eventService.getEventos();
  }

  Future<void> _refresh() async {
    setState(() {
      _eventosFuture = _eventService.getEventos();
    });
  }

  Color _chipBg(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'académico':
      case 'academico':
        return const Color(0xFFDDEBFF);
      case 'cultural':
        return const Color(0xFFEEDCFF);
      case 'deportivo':
        return const Color(0xFFDFF6DF);
      default:
        return const Color(0xFFE9ECEF);
    }
  }

  Color _chipFg(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'académico':
      case 'academico':
        return const Color(0xFF2F6FED);
      case 'cultural':
        return const Color(0xFF7A3DB8);
      case 'deportivo':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF495057);
    }
  }

  String _fechaHora(Evento e) {
    final f = e.fechaInicio;
    final day = f.day.toString().padLeft(2, '0');
    final month = f.month.toString().padLeft(2, '0');
    final year = f.year;
    final hour = f.hour.toString().padLeft(2, '0');
    final min = f.minute.toString().padLeft(2, '0');
    return '$day/$month/$year, $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Evento>>(
        future: _eventosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    'Error cargando eventos:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }

          final eventos = snapshot.data ?? [];
          if (eventos.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No hay eventos para validar.')),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final e = eventos[index];
              return _EventoCard(
                evento: e,
                chipBg: _chipBg(e.categoriaNombre),
                chipFg: _chipFg(e.categoriaNombre),
                fechaHora: _fechaHora(e),
                onAprobar: () async {
                  try {
                    await _eventService.aprobarEvento(e.idEvento);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Evento aprobado')),
                    );
                    await _refresh();
                  } catch (err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al aprobar: $err')),
                    );
                  }
                },
                onRechazar: () async {
                  try {
                    await _eventService.rechazarEvento(e.idEvento);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Evento rechazado')),
                    );
                    await _refresh();
                  } catch (err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al rechazar: $err')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EventosScreen extends StatelessWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Validación de eventos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const EventosContent(),
      // keep navigation bar here for standalone usage; AdminShell will provide its own
    );
  }
}

class _EventoCard extends StatelessWidget {
  final Evento evento;
  final Color chipBg;
  final Color chipFg;
  final String fechaHora;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;

  const _EventoCard({
    required this.evento,
    required this.chipBg,
    required this.chipFg,
    required this.fechaHora,
    required this.onAprobar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Izquierda: textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    evento.categoriaNombre,
                    style: TextStyle(
                      color: chipFg,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  evento.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      fechaHora,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text(
                  evento.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    OutlinedButton(
                      onPressed: onRechazar,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      child: const Text('Rechazar'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: onAprobar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E60A8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Validar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Derecha: imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: _EventoImage(
                url: evento.foto ?? 'https://via.placeholder.com/150',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventoImage extends StatelessWidget {
  final String url;
  const _EventoImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return Container(
        color: const Color(0xFFE5E7EB),
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }

    // Si "foto" es una URL pública, esto sirve:
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFE5E7EB),
        child: const Icon(Icons.broken_image_outlined),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}

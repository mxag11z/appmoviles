import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/event_service.dart';
import '../data/models/evento_model.dart';

class MisEventosScreen extends StatefulWidget {
  const MisEventosScreen({super.key});

  @override
  State<MisEventosScreen> createState() => _MisEventosScreenState();
}

class _MisEventosScreenState extends State<MisEventosScreen> {
  final CrudEventService eventService = CrudEventService();
  late Future<List<Evento>> _eventosFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  void _cargarEventos() {
    _eventosFuture = eventService.obtenerEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validación de eventos'), elevation: 0),
      body: FutureBuilder<List<Evento>>(
        future: _eventosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventos = snapshot.data ?? [];

          if (eventos.isEmpty) {
            return const Center(
              child: Text('Aún no tienes eventos registrados'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              return _EventoCard(
                evento: evento,
                onAprobar: () async {
                  await eventService.aprobarEvento(evento.idEvento);
                  setState(_cargarEventos);
                },
                onRechazar: () async {
                  await eventService.cancelarEvento(evento.idEvento);
                  setState(_cargarEventos);
                },
              );
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() => _currentIndex = index);

          switch (index) {
            case 0:
              context.go('/organizador/eventos-aprobacion');
              break;
            case 1:
              context.go('/organizador/eventos-aprobados');
              break;
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_top),
            label: 'En aprobación',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Aprobados',
          ),
        ],
      ),
    );
  }
}

/* ===========================================================
   ======================= EVENT CARD =========================
   =========================================================== */

class _EventoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;

  const _EventoCard({
    required this.evento,
    required this.onAprobar,
    required this.onRechazar,
  });

  String _categoriaTexto(int fk) {
    switch (fk) {
      case 1:
        return 'Académico';
      case 2:
        return 'Cultural';
      case 3:
        return 'Deportivo';
      default:
        return 'Otro';
    }
  }

  Color _categoriaColor(int fk) {
    switch (fk) {
      case 1:
        return Colors.blue.shade100;
      case 2:
        return Colors.purple.shade100;
      case 3:
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _categoriaTextColor(int fk) {
    switch (fk) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.green;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CATEGORÍA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _categoriaColor(evento.categoriaFk),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _categoriaTexto(evento.categoriaFk),
              style: TextStyle(
                fontSize: 12,
                color: _categoriaTextColor(evento.categoriaFk),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // TITULO
          Text(
            evento.titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          // FECHA
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  evento.fechaInicio.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),



          const SizedBox(height: 8),

          // descripcion
          Text(
            evento.descripcion,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87),
          ),


          Text(
            'Ubicación: ${evento.ubicacion}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 12),

          // IMAGEN (100% segura)
          if (evento.foto.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                evento.foto,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 14),

          // botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRechazar,
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAprobar,
                  child: const Text('Aprobar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

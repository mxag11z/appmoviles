import 'package:flutter/material.dart';
import '../../../services/event_service.dart';
import '../../../data/models/evento_model.dart';

class EventosAdminScreen extends StatefulWidget {
  const EventosAdminScreen({super.key});

  @override
  State<EventosAdminScreen> createState() => _EventosAdminScreenState();
}

class _EventosAdminScreenState extends State<EventosAdminScreen> {
  final EventService _eventService = EventService();
  late Future<List<Evento>> _eventosFuture;

  @override
  void initState() {
    super.initState();
    _eventosFuture = _eventService.getTodosLosEventos();
  }

  Future<void> _refresh() async {
    setState(() {
      _eventosFuture = _eventService.getTodosLosEventos();
    });
  }

  String _estadoLabel(String statusFk) {
    switch (statusFk) {
      case '1': return 'Rechazado';
      case '2': return 'Aprobado';
      case '3': return 'Pendiente';
      default: return 'Desconocido';
    }
  }

  Color _estadoBg(String statusFk) {
    switch (statusFk) {
      case '1': return Colors.red.shade50;
      case '2': return Colors.green.shade50;
      case '3': return Colors.orange.shade50;
      default: return Colors.grey.shade200;
    }
  }

  Color _estadoFg(String statusFk) {
    switch (statusFk) {
      case '1': return Colors.red.shade700;
      case '2': return Colors.green.shade700;
      case '3': return Colors.orange.shade700;
      default: return Colors.grey.shade700;
    }
  }

  String _chipLabel(String categoria) {
    final c = categoria.toLowerCase();
    if (c.contains('acad')) return 'Académico';
    if (c.contains('cult')) return 'Cultural';
    if (c.contains('deport')) return 'Deportivo';
    return categoria;
  }

  Color _chipBg(String categoria) {
    final c = categoria.toLowerCase();
    if (c.contains('acad')) return const Color(0xFFE6F0FF);
    if (c.contains('cult')) return const Color(0xFFF2E8FF);
    if (c.contains('deport')) return const Color(0xFFE8F7EA);
    return const Color(0xFFEFEFEF);
  }

  Color _chipFg(String categoria) {
    final c = categoria.toLowerCase();
    if (c.contains('acad')) return const Color(0xFF2F6FED);
    if (c.contains('cult')) return const Color(0xFF7A3AF9);
    if (c.contains('deport')) return const Color(0xFF2E7D32);
    return const Color(0xFF333333);
  }

  String _formatFechaHora(Evento e) {
    final d = e.fechaInicio;
    final meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    final hora = (d.hour % 12 == 0) ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} de ${meses[d.month - 1]}, $hora:$mm $ampm';
  }

  Future<void> _cambiarEstado(String idEvento, String nuevoEstado) async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      
      // Mostrar indicador de carga
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Actualizando evento...'),
          duration: Duration(seconds: 1),
        ),
      );

      if (nuevoEstado == 'aprobado') {
        await _eventService.aprobarEvento(idEvento);
      } else if (nuevoEstado == 'rechazado') {
        await _eventService.rechazarEvento(idEvento);
      } else if (nuevoEstado == 'pendiente') {
        await _eventService.volverAPendiente(idEvento);
      }

      // Actualizar la lista
      await _refresh();

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Evento ${nuevoEstado == "aprobado" ? "aprobado" : nuevoEstado == "rechazado" ? "rechazado" : "marcado como pendiente"} exitosamente'),
          backgroundColor: nuevoEstado == 'aprobado' ? Colors.green : nuevoEstado == 'rechazado' ? Colors.red : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar evento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      appBar: AppBar(
        title: const Text('Todos los eventos'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Evento>>(
        future: _eventosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error cargando eventos:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final eventos = snapshot.data ?? [];
          if (eventos.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 80),
                  Icon(Icons.event_busy, size: 48),
                  SizedBox(height: 12),
                  Center(child: Text('No hay eventos por mostrar')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: eventos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = eventos[i];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _chipBg(e.categoria),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _chipLabel(e.categoria),
                                style: TextStyle(
                                  color: _chipFg(e.categoria),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _estadoBg(e.estado),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _estadoLabel(e.estado),
                                style: TextStyle(
                                  color: _estadoFg(e.estado),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.titulo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatFechaHora(e),
                                        style: const TextStyle(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    e.descripcion,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.black54, height: 1.35),
                                  ),
                                  // Botón de volver a validar
                                  if (e.estado == '2' || e.estado == '1') ...[
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _cambiarEstado(e.idEvento, 'pendiente'),
                                      icon: const Icon(Icons.undo, size: 18),
                                      label: const Text('Volver a validar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 84,
                                height: 84,
                                child: (e.foto.isNotEmpty && e.foto.startsWith('http'))
                                    ? Image.network(e.foto, fit: BoxFit.cover)
                                    : Container(
                                        color: const Color(0xFFEDEFF5),
                                        child: const Icon(Icons.image_outlined, color: Colors.black38),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

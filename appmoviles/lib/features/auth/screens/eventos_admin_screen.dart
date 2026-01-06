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

  String _estadoLabel(String status) {
    if (status == '1') return 'Pendiente';
    if (status == '2') return 'Rechazado';
    if (status == '3')
      return 'Aprobado'; // Publicado se muestra como Aprobado en la UI
    return 'Sin estado';
  }

  Color _estadoBg(String status) {
    if (status == '1')
      return const Color(0xFFFFF3E0); // Naranja pastel (Pendiente)
    if (status == '2')
      return const Color(0xFFFFEBEE); // Rojo pastel (Rechazado)
    if (status == '3')
      return const Color(0xFFE8F5E9); // Verde pastel (Aprobado/Publicado)
    return const Color(0xFFF1F3F7);
  }

  Color _estadoFg(String status) {
    if (status == '1') return const Color(0xFFFF9800); // Naranja texto
    if (status == '2') return const Color(0xFFEF5350); // Rojo texto
    if (status == '3') return const Color(0xFF66BB6A); // Verde texto
    return Colors.black45;
  }

  // 2. Formato de Fecha (idéntico a imagen_af85d3.png)
  String _formatFechaHora(DateTime d) {
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
      'Diciembre',
    ];
    final hora = (d.hour % 12 == 0) ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} de ${meses[d.month - 1]}, $hora:$mm $ampm';
  }

  Future<void> _cambiarEstado(String idEvento) async {
    await _eventService.volverAPendiente(idEvento);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Todos los eventos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<Evento>>(
        future: _eventosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final eventos = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: eventos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, i) {
                final e = eventos[i];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      28,
                    ), // Bordes muy redondeados como la imagen
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Badge ID Categoria (Gris suave)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                e.categoriaFk.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Badge de Estado de Color
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _estadoBg(e.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _estadoLabel(e.status),
                                style: TextStyle(
                                  color: _estadoFg(e.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1A1C1E),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: Colors.black38,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatFechaHora(e.fechaInicio),
                                        style: const TextStyle(
                                          color: Colors.black38,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    e.descripcion,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  // Botón Naranja "Volver a validar" (Solo si no está pendiente)
                                  if (e.status != '3')
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _cambiarEstado(e.idEvento),
                                      icon: const Icon(
                                        Icons.undo,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Volver a validar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFB8C00,
                                        ), // Naranja exacto
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Imagen a la derecha
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 90,
                                height: 90,
                                color: const Color(0xFFF1F3F7),
                                child:
                                    (e.foto != null &&
                                        e.foto!.isNotEmpty &&
                                        e.foto!.startsWith('http'))
                                    ? Image.network(
                                        e.foto!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.black26,
                                            ),
                                      )
                                    : const Icon(
                                        Icons.image_outlined,
                                        color: Colors.black26,
                                        size: 35,
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

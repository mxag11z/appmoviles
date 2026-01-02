import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/event_service.dart';
import '../data/models/evento_model.dart';

const Map<int, String> categorias = {
  1: 'General',
  2: 'Tecnología',
  3: 'Arte',
  4: 'Deportes',
  5: 'Música',
  6: 'Ciencia',
};

class EventosAprobadosScreen extends StatefulWidget {
  const EventosAprobadosScreen({super.key});

  @override
  State<EventosAprobadosScreen> createState() => _EventosAprobadosScreenState();
}

class _EventosAprobadosScreenState extends State<EventosAprobadosScreen> {
  final CrudEventService eventService = CrudEventService();
  late Future<List<Evento>> _eventosFuture;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  void _cargarEventos() {
    _eventosFuture = eventService.obtenerEventosAprobados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos aprobados'), elevation: 0),

      body: FutureBuilder<List<Evento>>(
        future: _eventosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventos = snapshot.data ?? [];

          if (eventos.isEmpty) {
            return const Center(child: Text('No hay eventos aprobados'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];

              return _EventoAprobadoCard(
                evento: evento,
                onInvitados: () {
                  context.go(
                    '/organizador/evento/${evento.idEvento}/invitados',
                  );
                },
                onEditar: () {
                  _mostrarEditarEvento(context, evento);
                },
              );
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() => _currentIndex = index);

          if (index == 0) {
            context.go('/organizador/mis_eventos');
          } else {
            context.go('/organizador/eventos-aprobados');
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

  /// ================= EDITAR EVENTO (BOTTOM SHEET) =================
  void _mostrarEditarEvento(BuildContext context, Evento evento) {
  final tituloCtrl = TextEditingController(text: evento.titulo);
  final descripcionCtrl = TextEditingController(text: evento.descripcion);
  final cupoCtrl = TextEditingController(text: evento.cupo.toString());

  DateTime fechaInicio = evento.fechaInicio;
  DateTime fechaFin = evento.fechaFin;
  int categoriaSeleccionada = evento.categoriaFk;

  File? nuevaImagen;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar evento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  /// TÍTULO
                  TextField(
                    controller: tituloCtrl,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),

                  const SizedBox(height: 10),

                  /// DESCRIPCIÓN
                  TextField(
                    controller: descripcionCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 10),

                  /// CUPO
                  TextField(
                    controller: cupoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cupo de invitados',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Ubicación: ${evento.ubicacion}',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  /// CATEGORÍA
                  DropdownButtonFormField<int>(
                    value: categoriaSeleccionada,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categorias.entries.map((e) {
                      return DropdownMenuItem<int>(
                        value: e.key,
                        child: Text(e.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => categoriaSeleccionada = value);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  /// FECHA INICIO
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha inicio'),
                    subtitle: Text(
                      '${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: fechaInicio,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => fechaInicio = picked);
                      }
                    },
                  ),

                  /// FECHA FIN
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha fin'),
                    subtitle: Text(
                      '${fechaFin.day}/${fechaFin.month}/${fechaFin.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: fechaFin,
                        firstDate: fechaInicio,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => fechaFin = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  /// IMAGEN
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text('Cambiar imagen'),
                    onPressed: () async {
                      // image_picker aquí
                    },
                  ),

                  const SizedBox(height: 16),

                  /// BOTONES
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final eventoEditado = Evento(
                              idEvento: evento.idEvento,
                              titulo: tituloCtrl.text.trim(),
                              descripcion: descripcionCtrl.text.trim(),
                              fechaInicio: fechaInicio,
                              fechaFin: fechaFin,
                              ubicacion: evento.ubicacion,
                              cupo: int.parse(cupoCtrl.text),
                              organizadorFK: evento.organizadorFK,
                              categoriaFk: categoriaSeleccionada,
                              categoriaNombre: categorias[categoriaSeleccionada] ?? 'Sin categoría',
                              foto: evento.foto,
                              status: evento.status,
                            );

                            final error = await eventService.editarEvento(
                              idEvento: evento.idEvento,
                              evento: eventoEditado,
                            );

                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                              return;
                            }

                            Navigator.pop(context);
                            setState(_cargarEventos);
                          },
                          child: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

}

/* ===========================================================
   ===================== EVENT CARD ===========================
   =========================================================== */

class _EventoAprobadoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback onInvitados;
  final VoidCallback onEditar;

  const _EventoAprobadoCard({
    required this.evento,
    required this.onInvitados,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final categoriaNombre =
        categorias[evento.categoriaFk] ?? 'Sin categoría';

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
          ///titulo
          Text(
            evento.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          /// CATEGORÍA + CUPO
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  categoriaNombre,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cupo: ${evento.cupo}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ///fechas 
          Text(
            '${_formatearFecha(evento.fechaInicio)} - ${_formatearFecha(evento.fechaFin)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          ///descripcion
          Text(
            evento.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          ///imagen
          if (evento.foto != null && evento.foto!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                evento.foto!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 14),

          ///botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.group),
                  label: const Text('Invitados'),
                  onPressed: onInvitados,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: onEditar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// formatea una fecha a dd/mm/yyyy
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}

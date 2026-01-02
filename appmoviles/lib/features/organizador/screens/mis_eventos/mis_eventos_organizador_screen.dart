import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/event_service.dart';
import '../../../../data/models/evento_model.dart';

const Map<int, String> categorias = {
  1: 'General',
  2: 'Tecnología',
  3: 'Arte',
  4: 'Deportes',
  5: 'Música',
  6: 'Ciencia',
};

class MisEventosOrganizadorScreen extends StatefulWidget {
  const MisEventosOrganizadorScreen({super.key});

  @override
  State<MisEventosOrganizadorScreen> createState() =>
      _MisEventosOrganizadorScreenState();
}

class _MisEventosOrganizadorScreenState
    extends State<MisEventosOrganizadorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CrudEventService eventService = CrudEventService();

  late Future<List<Evento>> _pendientesFuture;
  late Future<List<Evento>> _aprobadosFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarEventos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cargarEventos() {
    _pendientesFuture = eventService.obtenerEventos(); // status pending
    _aprobadosFuture = eventService.obtenerEventosAprobados(); // status approved
  }

  void _refresh() {
    setState(_cargarEventos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Mis Eventos',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(
              icon: Icon(Icons.hourglass_top),
              text: 'Pendientes',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Aprobados',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Eventos pendientes
          _EventosList(
            future: _pendientesFuture,
            emptyMessage: 'No hay eventos pendientes',
            isPendingTab: true,
            onAprobar: (evento) async {
              await eventService.aprobarEvento(evento.idEvento);
              _refresh();
            },
            onRechazar: (evento) async {
              await eventService.cancelarEvento(evento.idEvento);
              _refresh();
            },
            onRefresh: _refresh,
          ),

          // Tab 2: Eventos aprobados
          _EventosList(
            future: _aprobadosFuture,
            emptyMessage: 'No hay eventos aprobados',
            isPendingTab: false,
            onEditar: (evento) => _mostrarEditarEvento(context, evento),
            onVerInvitados: (evento) {
              context.push('/organizador/evento/${evento.idEvento}/invitados');
            },
            onRefresh: _refresh,
          ),
        ],
      ),
    );
  }

  void _mostrarEditarEvento(BuildContext context, Evento evento) {
    final tituloCtrl = TextEditingController(text: evento.titulo);
    final descripcionCtrl = TextEditingController(text: evento.descripcion);
    final cupoCtrl = TextEditingController(text: evento.cupo.toString());

    DateTime fechaInicio = evento.fechaInicio;
    DateTime fechaFin = evento.fechaFin;
    int categoriaSeleccionada = evento.categoriaFk;

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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Editar evento',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descripcionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cupoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cupo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: categoriaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              '${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}',
                            ),
                            onPressed: () async {
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              '${fechaFin.day}/${fechaFin.month}/${fechaFin.year}',
                            ),
                            onPressed: () async {
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                                cupo: int.tryParse(cupoCtrl.text) ?? evento.cupo,
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

                              if (context.mounted) {
                                Navigator.pop(context);
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Evento actualizado'),
                                      backgroundColor: Color(0xFF059669),
                                    ),
                                  );
                                  _refresh();
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
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

class _EventosList extends StatelessWidget {
  final Future<List<Evento>> future;
  final String emptyMessage;
  final bool isPendingTab;
  final Function(Evento)? onAprobar;
  final Function(Evento)? onRechazar;
  final Function(Evento)? onEditar;
  final Function(Evento)? onVerInvitados;
  final VoidCallback onRefresh;

  const _EventosList({
    required this.future,
    required this.emptyMessage,
    required this.isPendingTab,
    this.onAprobar,
    this.onRechazar,
    this.onEditar,
    this.onVerInvitados,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Evento>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final eventos = snapshot.data ?? [];

        if (eventos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPendingTab ? Icons.hourglass_empty : Icons.event_available,
                  size: 64,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              return _EventoCard(
                evento: evento,
                isPending: isPendingTab,
                onAprobar: onAprobar != null ? () => onAprobar!(evento) : null,
                onRechazar:
                    onRechazar != null ? () => onRechazar!(evento) : null,
                onEditar: onEditar != null ? () => onEditar!(evento) : null,
                onVerInvitados: onVerInvitados != null
                    ? () => onVerInvitados!(evento)
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}

class _EventoCard extends StatelessWidget {
  final Evento evento;
  final bool isPending;
  final VoidCallback? onAprobar;
  final VoidCallback? onRechazar;
  final VoidCallback? onEditar;
  final VoidCallback? onVerInvitados;

  const _EventoCard({
    required this.evento,
    required this.isPending,
    this.onAprobar,
    this.onRechazar,
    this.onEditar,
    this.onVerInvitados,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          if (evento.foto != null && evento.foto!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                evento.foto!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: const Color(0xFFE5E7EB),
                  child: const Icon(Icons.image, size: 48, color: Colors.grey),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoría
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    evento.categoriaNombre,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Título
                Text(
                  evento.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 8),

                // Fecha y ubicación
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      '${evento.fechaInicio.day}/${evento.fechaInicio.month}/${evento.fechaInicio.year}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on,
                        size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        evento.ubicacion,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Cupo
                Row(
                  children: [
                    const Icon(Icons.people,
                        size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      'Cupo: ${evento.cupo ?? 'Sin límite'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Descripción
                Text(
                  evento.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),

                const SizedBox(height: 16),

                // Botones
                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onRechazar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                          ),
                          child: const Text('Rechazar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAprobar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Aprobar'),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onVerInvitados,
                          icon: const Icon(Icons.people, size: 18),
                          label: const Text('Invitados'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onEditar,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

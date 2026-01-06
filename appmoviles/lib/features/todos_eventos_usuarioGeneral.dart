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

class AllEventosScreen extends StatefulWidget {
  const AllEventosScreen({super.key});

  @override
  State<AllEventosScreen> createState() => _AllEventosScreenState();
}

class _AllEventosScreenState extends State<AllEventosScreen> {
  final CrudEventService eventService = CrudEventService();
  late Future<List<Evento>> _eventosFuture;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  void _cargarEventos() {
    _eventosFuture = eventService.obtenerTodosEventos();
  }

  /* ===================== para los filtros ===================== */

  void _mostrarFiltros() {
    int? categoria;
    String ubicacion = '';
    DateTime? fechaInicio;
    DateTime? fechaFin;

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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// CATEGORÍA
                    DropdownButtonFormField<int>(
                      value: categoria,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: categorias.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() => categoria = value);
                      },
                    ),

                    const SizedBox(height: 10),

                    /// UBICACIÓN
                    TextField(
                      decoration: const InputDecoration(labelText: 'Ubicación'),
                      onChanged: (value) => ubicacion = value,
                    ),

                    const SizedBox(height: 10),

                    /// FECHA INICIO
                    ListTile(
                      title: const Text('Fecha inicio'),
                      subtitle: Text(
                        fechaInicio == null
                            ? 'Seleccionar'
                            : _formatearFecha(fechaInicio!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
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
                      title: const Text('Fecha fin'),
                      subtitle: Text(
                        fechaFin == null
                            ? 'Seleccionar'
                            : _formatearFecha(fechaFin!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fechaInicio ?? DateTime.now(),
                          firstDate: fechaInicio ?? DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() => fechaFin = picked);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    /// APLICAR
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _aplicarFiltros(
                            categoria: categoria,
                            ubicacion: ubicacion,
                            fechaInicio: fechaInicio,
                            fechaFin: fechaFin,
                          );
                        },
                        child: const Text('Aplicar filtros'),
                      ),
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

  void _aplicarFiltros({
    int? categoria,
    String? ubicacion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    setState(() {
      _eventosFuture = eventService.obtenerEventosFiltrados(
        categoria: categoria,
        ubicacion: ubicacion,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
    });
  }

  /* ===================== UI ===================== */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los eventos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
        ],
      ),

      body: FutureBuilder<List<Evento>>(
        future: _eventosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventos = snapshot.data ?? [];

          if (eventos.isEmpty) {
            return const Center(child: Text('No hay eventos disponibles'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              return _EventoCard(evento: eventos[index]);
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.grey[600],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          //if (index == _currentIndex) return;

          if (index == 0) {
            context.go('/onboarding');
          } else {
            context.go('/login');
          }

          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Iniciar'),
        ],
      ),
    );
  }
}

/* ===================== EVENT CARD ===================== */

class _EventoCard extends StatelessWidget {
  final Evento evento;

  const _EventoCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    final categoriaNombre = categorias[evento.categoriaFk] ?? 'Sin categoría';

    final bool estaCerrado = evento.status == 2;

    return Opacity(
      opacity: estaCerrado ? 0.45 : 1,
      child: Container(
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
            Text(
              evento.titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // categoría y cupo
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
                const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Cupo: ${evento.cupo}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ubicación
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Ubicación: ${evento.ubicacion}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // fecha y hora
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${_formatearFecha(evento.fechaInicio)} - ${_formatearFecha(evento.fechaFin)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              '${_formatearFecha(evento.fechaInicio)} - ${_formatearFecha(evento.fechaFin)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 8),

            Text(
              evento.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

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

            if (!estaCerrado)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text('Inscribirse'),
                ),
              ),

            if (estaCerrado)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Evento cerrado',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ===================== UTIL ===================== */

String _formatearFecha(DateTime fecha) {
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '${fecha.day}/${fecha.month}/${fecha.year} $hora:$minuto';
}

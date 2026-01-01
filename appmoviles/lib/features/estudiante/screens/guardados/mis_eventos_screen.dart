import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/providers.dart';
import '../../../../data/models/evento_model.dart';

class MisEventosScreen extends ConsumerWidget {
  const MisEventosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myEventsAsync = ref.watch(myRegisteredEventsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════
            // HEADER
            // ═══════════════════════════════════════════════════════
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Mis Eventos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Eventos a los que te has registrado',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════
            // LISTA DE EVENTOS REGISTRADOS
            // ═══════════════════════════════════════════════════════
            Expanded(
              child: myEventsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(myRegisteredEventsProvider.notifier).refresh();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
                data: (eventos) {
                  if (eventos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No tienes eventos registrados',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Explora eventos y regístrate',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.go('/estudiante/home');
                            },
                            icon: const Icon(Icons.explore),
                            label: const Text('Explorar eventos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(myRegisteredEventsProvider.notifier).refresh();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: eventos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final evento = eventos[index];
                        return _RegisteredEventCard(
                          evento: evento,
                          onTap: () {
                            context.push('/estudiante/evento', extra: evento);
                          },
                          onUnregister: () {
                            _showUnregisterDialog(context, ref, evento);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnregisterDialog(BuildContext context, WidgetRef ref, Evento evento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Cancelar registro',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cancelar tu registro en "${evento.titulo}"?',
          style: const TextStyle(
            color: Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No, mantener',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(myRegisteredEventsProvider.notifier)
                  .unregisterFromEvent(evento.idEvento);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Registro cancelado exitosamente'
                          : 'Error al cancelar el registro',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor:
                        success ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// WIDGET: TARJETA DE EVENTO REGISTRADO
// ═══════════════════════════════════════════════════════════════════
class _RegisteredEventCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback onTap;
  final VoidCallback onUnregister;

  const _RegisteredEventCard({
    required this.evento,
    required this.onTap,
    required this.onUnregister,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = evento.fechaFin.isBefore(DateTime.now());

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ═══════════════════════════════════════════════════
              // IMAGEN DEL EVENTO
              // ═══════════════════════════════════════════════════
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 68,
                  height: 68,
                  color: const Color(0xFFE9EDF5),
                  child: (evento.foto == null || evento.foto!.isEmpty)
                      ? const Icon(Icons.event, color: Color(0xFF6B7280))
                      : Image.network(
                          evento.foto!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // ═══════════════════════════════════════════════════
              // INFORMACIÓN DEL EVENTO
              // ═══════════════════════════════════════════════════
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          evento.categoriaNombre.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                            letterSpacing: 0.6,
                          ),
                        ),
                        if (isPast) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B7280).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PASADO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      evento.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(evento.fechaInicio)} · ${evento.ubicacion}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // ═══════════════════════════════════════════════════
              // BOTÓN CANCELAR REGISTRO
              // ═══════════════════════════════════════════════════
              IconButton(
                onPressed: onUnregister,
                icon: const Icon(Icons.close),
                color: const Color(0xFFDC2626),
                tooltip: 'Cancelar registro',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}

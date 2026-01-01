import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/evento_model.dart';
import '../../../../providers/providers.dart';

class EventoDetalleScreen extends ConsumerWidget {
  final Evento evento;

  const EventoDetalleScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizadorAsync = ref.watch(
      organizadorNameProvider(evento.organizadorFK),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF111827),
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  title: const Text(
                    'Detalle del Evento',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeroImage(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.titulo,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 24),

                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          iconColor: const Color(0xFF2563EB),
                          title: _formatDateLong(evento.fechaInicio),
                          subtitle: _formatTimeRange(
                            evento.fechaInicio,
                            evento.fechaFin,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          iconColor: const Color(0xFF2563EB),
                          title: evento.ubicacion,
                          subtitle: 'Campus Universitario',
                        ),

                        const SizedBox(height: 16),

                        _CupoInfoRow(
                          cupo: evento.cupo,
                          eventoId: evento.idEvento,
                        ),

                        const SizedBox(height: 24),
                        const Divider(
                          color: Color(0xFFE5E7EB),
                          thickness: 1,
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Organizador',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),

                        const SizedBox(height: 12),

                        organizadorAsync.when(
                          data: (nombre) => _OrganizadorCard(
                            nombre: nombre ?? 'Organizador no disponible',
                          ),
                          loading: () => const _OrganizadorCard(
                            nombre: 'Cargando...',
                            isLoading: true,
                          ),
                          error: (_, __) => const _OrganizadorCard(
                            nombre: 'Error al cargar organizador',
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Acerca del evento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          evento.descripcion.isNotEmpty
                              ? evento.descripcion
                              : 'No hay descripción disponible para este evento.',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4B5563),
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: _RegistroButton(
        eventoId: evento.idEvento,
        cupo: evento.cupo,
      ),
    );
  }
  Widget _buildHeroImage() {
    if (evento.foto == null || evento.foto!.isEmpty) {
      return Container(
        color: const Color(0xFFE9EDF5),
        child: const Center(
          child: Icon(
            Icons.event,
            size: 64,
            color: Color(0xFF6B7280),
          ),
        ),
      );
    }

    return Image.network(
      evento.foto!,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFE9EDF5),
        child: const Center(
          child: Icon(
            Icons.broken_image,
            size: 64,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FORMAT DATE: "15 de Octubre, 2024"
  // ═══════════════════════════════════════════════════════════════════════
  String _formatDateLong(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FORMAT TIME RANGE: "10:00 AM - 12:00 PM"
  // ═══════════════════════════════════════════════════════════════════════
  String _formatTimeRange(DateTime start, DateTime end) {
    String formatTime(DateTime dt) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
    return '${formatTime(start)} - ${formatTime(end)}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class _CupoInfoRow extends ConsumerWidget {
  final int? cupo;
  final String eventoId;

  const _CupoInfoRow({
    required this.cupo,
    required this.eventoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registradosAsync = ref.watch(registradosCountProvider(eventoId));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.people_outline,
            color: Color(0xFF2563EB),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              registradosAsync.when(
                data: (registrados) {
                  if (cupo != null) {
                    final disponibles = cupo! - registrados;
                    final isFull = disponibles <= 0;
                    return Text(
                      '$registrados / $cupo registrados',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isFull ? const Color(0xFFDC2626) : const Color(0xFF111827),
                      ),
                    );
                  } else {
                    return Text(
                      '$registrados registrados',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    );
                  }
                },
                loading: () => const Text(
                  'Cargando...',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                error: (_, __) => const Text(
                  'Error al cargar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              registradosAsync.when(
                data: (registrados) {
                  if (cupo != null) {
                    final disponibles = cupo! - registrados;
                    if (disponibles <= 0) {
                      return const Text(
                        'Cupo lleno',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFDC2626),
                        ),
                      );
                    }
                    return Text(
                      '$disponibles lugares disponibles',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    );
                  }
                  return const Text(
                    'Cupo ilimitado',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrganizadorCard extends StatelessWidget {
  final String nombre;
  final bool isLoading;

  const _OrganizadorCard({
    required this.nombre,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              nombre,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistroButton extends ConsumerStatefulWidget {
  final String eventoId;
  final int? cupo;

  const _RegistroButton({
    required this.eventoId,
    required this.cupo,
  });

  @override
  ConsumerState<_RegistroButton> createState() => _RegistroButtonState();
}

class _RegistroButtonState extends ConsumerState<_RegistroButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isRegisteredAsync = ref.watch(isRegisteredProvider(widget.eventoId));
    final registradosAsync = ref.watch(registradosCountProvider(widget.eventoId));

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: isRegisteredAsync.when(
            loading: () => _buildLoadingButton(),
            error: (_, __) => _buildErrorButton(),
            data: (isRegistered) {
              // Si ya está registrado, siempre puede cancelar
              if (isRegistered) {
                return _buildActionButton(
                  isRegistered: true,
                  isFull: false,
                );
              }

              // Si no está registrado, verificar cupo
              return registradosAsync.when(
                loading: () => _buildLoadingButton(),
                error: (_, __) => _buildErrorButton(),
                data: (registrados) {
                  final isFull = widget.cupo != null && registrados >= widget.cupo!;
                  return _buildActionButton(
                    isRegistered: false,
                    isFull: isFull,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE5E7EB),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorButton() {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE5E7EB),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Text('Error al cargar'),
    );
  }

  Widget _buildActionButton({
    required bool isRegistered,
    required bool isFull,
  }) {
    // Si el cupo está lleno y no está registrado, mostrar botón deshabilitado
    if (isFull && !isRegistered) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.block),
        label: const Text(
          'Cupo lleno',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B7280),
          disabledBackgroundColor: const Color(0xFF6B7280),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isLoading ? null : () => _handleRegistration(isRegistered),
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              isRegistered ? Icons.close : Icons.person_add_outlined,
            ),
      label: Text(
        _isLoading
            ? (isRegistered ? 'Cancelando...' : 'Registrando...')
            : (isRegistered ? 'Cancelar registro' : 'Registrarme'),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isRegistered
            ? const Color(0xFFDC2626)
            : const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> _handleRegistration(bool isCurrentlyRegistered) async {
    setState(() => _isLoading = true);

    final notifier = ref.read(myRegisteredEventsProvider.notifier);
    bool success;

    if (isCurrentlyRegistered) {
      success = await notifier.unregisterFromEvent(widget.eventoId);
    } else {
      success = await notifier.registerToEvent(widget.eventoId);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (isCurrentlyRegistered
                    ? 'Registro cancelado'
                    : 'Te has registrado al evento')
                : 'Error al procesar la solicitud',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? const Color(0xFF059669) : const Color(0xFFDC2626),
        ),
      );
    }
  }
}

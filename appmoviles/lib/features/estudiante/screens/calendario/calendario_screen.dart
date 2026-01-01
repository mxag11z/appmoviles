import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/providers.dart';
import '../../../../data/models/evento_model.dart';

class CalendarioScreen extends ConsumerStatefulWidget {
  const CalendarioScreen({super.key});

  @override
  ConsumerState<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends ConsumerState<CalendarioScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final myEventsAsync = ref.watch(myRegisteredEventsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Mi Calendario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Eventos a los que estás inscrito',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),

            // Calendario
            myEventsAsync.when(
              loading: () => const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $e'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(myRegisteredEventsProvider.notifier).refresh(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (eventos) {
                final eventDates = _getEventDates(eventos);
                final eventsForSelectedDay = _selectedDay != null
                    ? _getEventsForDay(eventos, _selectedDay!)
                    : <Evento>[];

                return Expanded(
                  child: Column(
                    children: [
                      // Calendario mensual
                      _MonthCalendar(
                        selectedMonth: _selectedMonth,
                        selectedDay: _selectedDay,
                        eventDates: eventDates,
                        onMonthChanged: (month) {
                          setState(() => _selectedMonth = month);
                        },
                        onDaySelected: (day) {
                          setState(() => _selectedDay = day);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Lista de eventos del día seleccionado
                      Expanded(
                        child: _selectedDay == null
                            ? _buildAllEventsSection(eventos)
                            : _buildSelectedDayEvents(eventsForSelectedDay),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, int> _getEventDates(List<Evento> eventos) {
    final Map<DateTime, int> dates = {};
    for (final evento in eventos) {
      final date = DateTime(
        evento.fechaInicio.year,
        evento.fechaInicio.month,
        evento.fechaInicio.day,
      );
      dates[date] = (dates[date] ?? 0) + 1;
    }
    return dates;
  }

  List<Evento> _getEventsForDay(List<Evento> eventos, DateTime day) {
    return eventos.where((e) {
      return e.fechaInicio.year == day.year &&
          e.fechaInicio.month == day.month &&
          e.fechaInicio.day == day.day;
    }).toList();
  }

  Widget _buildAllEventsSection(List<Evento> eventos) {
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
              'No tienes eventos próximos',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora y regístrate a eventos',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/estudiante/home'),
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

    // Ordenar eventos por fecha
    final sortedEventos = List<Evento>.from(eventos)
      ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

    // Agrupar por mes
    final Map<String, List<Evento>> groupedByMonth = {};
    for (final evento in sortedEventos) {
      final monthKey = _getMonthName(evento.fechaInicio);
      groupedByMonth.putIfAbsent(monthKey, () => []);
      groupedByMonth[monthKey]!.add(evento);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: groupedByMonth.length,
      itemBuilder: (context, index) {
        final month = groupedByMonth.keys.elementAt(index);
        final monthEvents = groupedByMonth[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                month,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            ...monthEvents.map((evento) => _EventCard(
                  evento: evento,
                  onTap: () => context.push('/estudiante/evento', extra: evento),
                )),
          ],
        );
      },
    );
  }

  Widget _buildSelectedDayEvents(List<Evento> eventos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatSelectedDay(_selectedDay!),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedDay = null),
                child: const Text('Ver todos'),
              ),
            ],
          ),
        ),
        Expanded(
          child: eventos.isEmpty
              ? const Center(
                  child: Text(
                    'No hay eventos este día',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: eventos.length,
                  itemBuilder: (context, index) {
                    final evento = eventos[index];
                    return _EventCard(
                      evento: evento,
                      onTap: () => context.push('/estudiante/evento', extra: evento),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedDay(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${days[date.weekday - 1]} ${date.day} de ${months[date.month - 1]}';
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime selectedMonth;
  final DateTime? selectedDay;
  final Map<DateTime, int> eventDates;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  const _MonthCalendar({
    required this.selectedMonth,
    required this.selectedDay,
    required this.eventDates,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header del mes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  onMonthChanged(DateTime(
                    selectedMonth.year,
                    selectedMonth.month - 1,
                  ));
                },
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF6B7280),
              ),
              Text(
                _getMonthYearString(selectedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              IconButton(
                onPressed: () {
                  onMonthChanged(DateTime(
                    selectedMonth.year,
                    selectedMonth.month + 1,
                  ));
                },
                icon: const Icon(Icons.chevron_right),
                color: const Color(0xFF6B7280),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Días del mes
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday;

    final days = <Widget>[];

    // Espacios vacíos antes del primer día
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox(width: 36, height: 36));
    }

    // Días del mes
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedMonth.year, selectedMonth.month, day);
      final hasEvents = eventDates.containsKey(date);
      final isSelected = selectedDay != null &&
          selectedDay!.year == date.year &&
          selectedDay!.month == date.month &&
          selectedDay!.day == date.day;
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      days.add(
        GestureDetector(
          onTap: () => onDaySelected(date),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : isToday
                      ? const Color(0xFFE0E7FF)
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF111827),
                  ),
                ),
                if (hasEvents && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days,
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _EventCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback onTap;

  const _EventCard({
    required this.evento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = evento.fechaFin.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Fecha
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isPast
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        evento.fechaInicio.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isPast
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                      Text(
                        _getShortMonth(evento.fechaInicio.month),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPast
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Info del evento
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              evento.titulo,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPast)
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
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              evento.ubicacion,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getShortMonth(int month) {
    const months = [
      'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return months[month - 1];
  }
}

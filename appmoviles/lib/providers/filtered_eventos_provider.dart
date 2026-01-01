import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/evento_model.dart';
import 'events_provider.dart';
import 'search_provider.dart';
import 'categoria_filtro_provider.dart';
import 'date_filter_provider.dart';
import 'ubicacion_filter_provider.dart';

final filteredEventsProvider = Provider<AsyncValue<List<Evento>>>((ref) {
  final eventsStateAsync = ref.watch(publishedEventsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final categoria = ref.watch(categoriaFiltroProvider);
  final selectedDate = ref.watch(dateFilterProvider);
  final ubicacion = ref.watch(ubicacionFilterProvider);

  return eventsStateAsync.whenData((eventosState) {
    return eventosState.eventos.where((e) {
      // Filtro por búsqueda
      final matchesQuery = query.isEmpty ||
          e.titulo.toLowerCase().contains(query) ||
          e.descripcion.toLowerCase().contains(query);

      // Filtro por categoría
      final matchesCategoria =
          categoria == null || e.categoriaNombre == categoria;

      // Filtro por fecha
      final matchesDate = _matchesDate(e.fechaInicio, selectedDate);

      // Filtro por ubicación
      final matchesUbicacion =
          ubicacion == null || e.ubicacion == ubicacion;

      return matchesQuery && matchesCategoria && matchesDate && matchesUbicacion;
    }).toList();
  });
});

/// Verifica si la fecha del evento coincide con la fecha seleccionada
bool _matchesDate(DateTime eventDate, DateTime? selectedDate) {
  if (selectedDate == null) return true;

  return eventDate.year == selectedDate.year &&
      eventDate.month == selectedDate.month &&
      eventDate.day == selectedDate.day;
}

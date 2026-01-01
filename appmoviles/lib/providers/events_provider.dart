import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/eventos_service.dart';
import '../data/models/evento_model.dart';


final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final eventoServiceProvider = Provider<EventoService>((ref) {
  final supabase = ref.read(supabaseProvider);
  return EventoService(supabase);
});

class EventosState {
  final List<Evento> eventos;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;

  const EventosState({
    required this.eventos,
    required this.hasMore,
    this.isLoadingMore = false,
    this.currentPage = 0,
  });

  EventosState copyWith({
    List<Evento>? eventos,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return EventosState(
      eventos: eventos ?? this.eventos,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}


class PublishedEventsNotifier extends AsyncNotifier<EventosState> {
  static const int pageSize = 20;

  @override
  Future<EventosState> build() async {
    return _loadInitialEvents();
  }

  Future<EventosState> _loadInitialEvents() async {
    final service = ref.read(eventoServiceProvider);
    final eventos = await service.fetchPublishedEvents(
      offset: 0,
      limit: pageSize,
    );

    return EventosState(
      eventos: eventos,
      hasMore: eventos.length == pageSize,
      currentPage: 0,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final service = ref.read(eventoServiceProvider);
      final nextPage = currentState.currentPage + 1;

      final newEventos = await service.fetchPublishedEvents(
        offset: nextPage * pageSize,
        limit: pageSize,
      );

      final allEventos = [...currentState.eventos, ...newEventos];

      state = AsyncData(EventosState(
        eventos: allEventos,
        hasMore: newEventos.length == pageSize,
        isLoadingMore: false,
        currentPage: nextPage,
      ));
    } catch (e, stack) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadInitialEvents());
  }
}

final publishedEventsProvider =
    AsyncNotifierProvider<PublishedEventsNotifier, EventosState>(
      PublishedEventsNotifier.new,
    );
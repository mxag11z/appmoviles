import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/providers.dart';
import 'widgets/filter_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Detectar cuando el usuario llega al final
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Cargar más cuando falten 200px para el final
      ref.read(publishedEventsProvider.notifier).loadMore();
    }
  }

  void _showFilterModal(BuildContext context) {
    final eventsState = ref.read(publishedEventsProvider).value;
    final eventos = eventsState?.eventos ?? [];

    final categorias = eventos
        .map((e) => e.categoriaNombre)
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final ubicaciones = eventos
        .map((e) => e.ubicacion)
        .where((u) => u.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        categorias: categorias,
        ubicaciones: ubicaciones,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsStateAsync = ref.watch(publishedEventsProvider);
    final filteredAsync = ref.watch(filteredEventsProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════
            // HEADER: Avatar + Nombre + Notificaciones
            // ═══════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/estudiante/perfil'),
                    child: profileAsync.when(
                      data: (profile) => CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE6E8EF),
                        backgroundImage: profile.usuario?.foto != null &&
                                profile.usuario!.foto!.isNotEmpty
                            ? NetworkImage(profile.usuario!.foto!)
                            : null,
                        child: profile.usuario?.foto == null ||
                                profile.usuario!.foto!.isEmpty
                            ? const Icon(Icons.person, color: Color(0xFF6B7280), size: 20)
                            : null,
                      ),
                      loading: () => const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE6E8EF),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE6E8EF),
                        child: Icon(Icons.person, color: Color(0xFF6B7280), size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: profileAsync.when(
                      data: (profile) => Text(
                        'Hola, ${profile.usuario?.nombre ?? 'Usuario'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      loading: () => const Text(
                        'Hola...',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      error: (_, __) => const Text(
                        'Hola, Usuario',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: ir a notificaciones
                    },
                    icon: const Icon(Icons.notifications_none),
                    color: const Color(0xFF111827),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════
            // BUSCADOR
            // ═══════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EDF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar eventos...',
                    hintStyle: TextStyle(color: Color(0xFF6B7280)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).setQuery(value);
                  },
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════
            // TÍTULO + BOTÓN DE FILTROS
            // ═══════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Próximos Eventos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showFilterModal(context);
                    },
                    icon: const Icon(Icons.tune),
                    color: const Color(0xFF2563EB),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════
            // LISTA DE EVENTOS CON LAZY LOADING Y PULL-TO-REFRESH
            // ═══════════════════════════════════════════════════════
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(publishedEventsProvider.notifier).refresh();
                },
                child: filteredAsync.when(
                  loading: () => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                  error: (e, stack) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 150),
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
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.invalidate(publishedEventsProvider);
                          },
                          child: const Text('Reintentar'),
                        ),
                      ),
                    ],
                  ),
                  data: (filteredEvents) {
                    if (filteredEvents.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 150),
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'No hay eventos disponibles',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Arrastra hacia abajo para actualizar',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      itemCount: filteredEvents.length + 1, // +1 para el loader
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        // ✅ Mostrar indicador de carga al final
                        if (i == filteredEvents.length) {
                          return eventsStateAsync.maybeWhen(
                            data: (state) {
                              if (state.isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else if (!state.hasMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'No hay más eventos',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            orElse: () => const SizedBox.shrink(),
                          );
                        }

                        // ✅ Renderizar tarjeta de evento
                        final ev = filteredEvents[i];
                        return _EventCard(
                          titulo: ev.titulo,
                          categoria: ev.categoriaNombre,
                          lugar: ev.ubicacion,
                          fecha: _formatDate(ev.fechaInicio),
                          fotoUrl: ev.foto,
                          onTap: () {
                            context.push('/estudiante/evento', extra: ev);
                          },
                          onSave: () {
                            // TODO: guardar en favoritos
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
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

// ═══════════════════════════════════════════════════════════════════
// WIDGET: TARJETA DE EVENTO
// ═══════════════════════════════════════════════════════════════════
class _EventCard extends StatelessWidget {
  final String titulo;
  final String categoria;
  final String lugar;
  final String fecha;
  final String? fotoUrl;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const _EventCard({
    required this.titulo,
    required this.categoria,
    required this.lugar,
    required this.fecha,
    required this.fotoUrl,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: (fotoUrl == null || fotoUrl!.isEmpty)
                      ? const Icon(Icons.event, color: Color(0xFF6B7280))
                      : Image.network(
                          fotoUrl!,
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
                    Text(
                      categoria.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$fecha · $lugar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ═══════════════════════════════════════════════════
              // BOTÓN GUARDAR
              // ═══════════════════════════════════════════════════
              IconButton(
                onPressed: onSave,
                icon: const Icon(Icons.bookmark_border),
                color: const Color(0xFF2563EB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../providers/providers.dart';

class FilterModal extends ConsumerWidget {
  final List<String> categorias;
  final List<String> ubicaciones;

  const FilterModal({
    super.key,
    required this.categorias,
    required this.ubicaciones,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriaSeleccionada = ref.watch(categoriaFiltroProvider);
    final selectedDate = ref.watch(dateFilterProvider);
    final ubicacionSeleccionada = ref.watch(ubicacionFilterProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(categoriaFiltroProvider.notifier).clear();
                  ref.read(dateFilterProvider.notifier).clear();
                  ref.read(ubicacionFilterProvider.notifier).clear();
                },
                child: const Text(
                  'Limpiar',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // CATEGORÍA
          // ═══════════════════════════════════════════════════════════════
          const Text(
            'Categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Todas',
                selected: categoriaSeleccionada == null,
                onTap: () {
                  ref.read(categoriaFiltroProvider.notifier).clear();
                },
              ),
              ...categorias.map(
                (cat) => _FilterChip(
                  label: cat,
                  selected: categoriaSeleccionada == cat,
                  onTap: () {
                    ref.read(categoriaFiltroProvider.notifier).setCategoria(cat);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // FECHA
          // ═══════════════════════════════════════════════════════════════
          const Text(
            'Fecha',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF2563EB),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      ref.read(dateFilterProvider.notifier).setDate(date);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedDate != null
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: selectedDate != null
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate != null
                              ? _formatDateLong(selectedDate)
                              : 'Seleccionar fecha',
                          style: TextStyle(
                            fontSize: 15,
                            color: selectedDate != null
                                ? const Color(0xFF111827)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (selectedDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    ref.read(dateFilterProvider.notifier).clear();
                  },
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF6B7280),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // UBICACIÓN
          // ═══════════════════════════════════════════════════════════════
          const Text(
            'Ubicación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Todas',
                selected: ubicacionSeleccionada == null,
                onTap: () {
                  ref.read(ubicacionFilterProvider.notifier).clear();
                },
              ),
              ...ubicaciones.map(
                (ubi) => _FilterChip(
                  label: ubi,
                  selected: ubicacionSeleccionada == ubi,
                  onTap: () {
                    ref.read(ubicacionFilterProvider.notifier).setUbicacion(ubi);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════════
          // BOTÓN APLICAR
          // ═══════════════════════════════════════════════════════════════
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Aplicar filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateLong(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

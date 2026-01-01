import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/notification_provider.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(profileProvider.notifier).refresh(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (profile) => RefreshIndicator(
            onRefresh: () => ref.read(profileProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Foto de perfil
                  _ProfilePhoto(
                    fotoUrl: profile.usuario?.foto,
                    isLoading: profile.isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Nombre completo
                  Text(
                    profile.nombreCompleto.isNotEmpty
                        ? profile.nombreCompleto
                        : 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Email
                  Text(
                    profile.usuario?.email ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sección: Información personal
                  _SectionCard(
                    title: 'Información personal',
                    children: [
                      _InfoTile(
                        icon: Icons.person_outline,
                        title: 'Nombre',
                        subtitle: profile.nombreCompleto.isNotEmpty
                            ? profile.nombreCompleto
                            : 'No configurado',
                        onTap: () => _showEditNombreDialog(context, ref, profile),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sección: Intereses (solo para estudiantes)
                  if (profile.estudiante != null)
                    _SectionCard(
                      title: 'Mis intereses',
                      children: [
                        _InfoTile(
                          icon: Icons.interests_outlined,
                          title: 'Intereses',
                          subtitle: profile.estudiante!.intereses.isNotEmpty
                              ? profile.estudiante!.intereses.join(', ')
                              : 'Sin intereses configurados',
                          onTap: () => _showEditInteresesDialog(context, ref, profile),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Sección: Notificaciones
                  const _NotificationSection(),

                  const SizedBox(height: 16),

                  // Sección: Cuenta
                  _SectionCard(
                    title: 'Cuenta',
                    children: [
                      _InfoTile(
                        icon: Icons.logout,
                        title: 'Cerrar sesión',
                        subtitle: 'Salir de tu cuenta',
                        showArrow: false,
                        titleColor: const Color(0xFFDC2626),
                        onTap: () => _showLogoutConfirmation(context, ref),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNombreDialog(
    BuildContext context,
    WidgetRef ref,
    ProfileState profile,
  ) {
    final nombreController = TextEditingController(
      text: profile.usuario?.nombre ?? '',
    );
    final apPaternoController = TextEditingController(
      text: profile.usuario?.apellidoPaterno ?? '',
    );
    final apMaternoController = TextEditingController(
      text: profile.usuario?.apellidoMaterno ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Editar nombre',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apPaternoController,
              decoration: const InputDecoration(
                labelText: 'Apellido paterno',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apMaternoController,
              decoration: const InputDecoration(
                labelText: 'Apellido materno',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(profileProvider.notifier).updateNombre(
                    nombre: nombreController.text.trim(),
                    apellidoPaterno: apPaternoController.text.trim(),
                    apellidoMaterno: apMaternoController.text.trim(),
                  );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Nombre actualizado' : 'Error al actualizar',
                    ),
                    backgroundColor:
                        success ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditInteresesDialog(
    BuildContext context,
    WidgetRef ref,
    ProfileState profile,
  ) {
    final intereses = List<String>.from(profile.estudiante?.intereses ?? []);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Editar intereses',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Agregar interés',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          setState(() {
                            intereses.add(controller.text.trim());
                            controller.clear();
                          });
                        }
                      },
                      icon: const Icon(Icons.add_circle),
                      color: const Color(0xFF2563EB),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (intereses.isEmpty)
                  const Text(
                    'No hay intereses agregados',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: intereses.map((interes) {
                      return Chip(
                        label: Text(interes),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => intereses.remove(interes));
                        },
                        backgroundColor: const Color(0xFFE0E7FF),
                        labelStyle: const TextStyle(color: Color(0xFF2563EB)),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await ref
                    .read(profileProvider.notifier)
                    .updateIntereses(intereses);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Intereses actualizados' : 'Error al actualizar',
                      ),
                      backgroundColor:
                          success ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(profileProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _ProfilePhoto extends ConsumerWidget {
  final String? fotoUrl;
  final bool isLoading;

  const _ProfilePhoto({
    required this.fotoUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE5E7EB),
            image: fotoUrl != null && fotoUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(fotoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: fotoUrl == null || fotoUrl!.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFF6B7280),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isLoading ? null : () => _pickAndUploadPhoto(context, ref),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadPhoto(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    final file = File(picked.path);
    final success = await ref.read(profileProvider.notifier).updateFoto(file);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Foto actualizada' : 'Error al actualizar la foto',
          ),
          backgroundColor:
              success ? const Color(0xFF059669) : const Color(0xFFDC2626),
        ),
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showArrow;
  final Color? titleColor;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showArrow = true,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (titleColor ?? const Color(0xFF2563EB)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: titleColor ?? const Color(0xFF2563EB),
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF6B7280),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSection extends ConsumerWidget {
  const _NotificationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Notificaciones',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: state.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  children: [
                    _NotificationTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notificaciones push',
                      subtitle: state.hasPermission
                          ? 'Activadas'
                          : 'Desactivadas',
                      trailing: Switch(
                        value: state.hasPermission,
                        onChanged: (value) async {
                          if (value) {
                            await ref
                                .read(notificationProvider.notifier)
                                .requestPermission();
                          }
                        },
                        activeTrackColor: const Color(0xFF2563EB),
                      ),
                    ),
                    if (state.hasPermission) ...[
                      const Divider(height: 1, indent: 74),
                      _NotificationTile(
                        icon: Icons.event_available,
                        title: 'Recordatorios de eventos',
                        subtitle: 'Recibe avisos antes de tus eventos',
                        trailing: Switch(
                          value: state.eventReminders,
                          onChanged: (value) {
                            ref
                                .read(notificationProvider.notifier)
                                .toggleEventReminders(value);
                          },
                          activeTrackColor: const Color(0xFF2563EB),
                        ),
                      ),
                      const Divider(height: 1, indent: 74),
                      _NotificationTile(
                        icon: Icons.new_releases_outlined,
                        title: 'Nuevos eventos',
                        subtitle: 'Entérate de eventos que te interesan',
                        trailing: Switch(
                          value: state.newEvents,
                          onChanged: (value) {
                            ref
                                .read(notificationProvider.notifier)
                                .toggleNewEvents(value);
                          },
                          activeTrackColor: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
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
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

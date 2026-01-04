import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacionesAdminScreen extends StatefulWidget {
  const NotificacionesAdminScreen({super.key});

  @override
  State<NotificacionesAdminScreen> createState() => _NotificacionesAdminScreenState();
}

class _NotificacionesAdminScreenState extends State<NotificacionesAdminScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final selectStr = 'id_usuario, nombre, ap_paterno, ap_materno, email, rolfk, foto';
    try {
      debugPrint('Executing select on usuario: $selectStr');
      final res = await _supabase.from('usuario').select(selectStr).order('nombre');
      return List<Map<String, dynamic>>.from(res);
    } catch (e, st) {
      debugPrint('Error in _fetchUsers (notificaciones): $e\n$st');
      rethrow;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text('Error: ${snapshot.error}')),
                ],
              );
            }
            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No hay usuarios.')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final u = users[i];
                final nombre = u['nombre'] ?? '';
                final apPat = u['ap_paterno'] ?? '';
                final apMat = u['ap_materno'] ?? '';
                final fullName = [nombre, apPat, apMat].where((x) => (x as String).trim().isNotEmpty).join(' ');
                final rol = (u['rol'] ?? u['rolfk'] ?? '—').toString();
                final correo = u['email'] ?? '—';
                final foto = (u['foto'] ?? '').toString().trim();

                return _UserCard(
                  nombre: fullName.isEmpty ? 'Sin nombre' : fullName,
                  rol: rol,
                  correo: correo,
                  foto: foto,
                  onDelete: () => _deleteUser(context, u),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context, Map<String, dynamic> user) async {
    final idUsuario = user['id_usuario']?.toString() ?? '';
    final nombre = user['nombre'] ?? 'este usuario';
    
    if (idUsuario.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _supabase.from('usuario').delete().eq('id_usuario', idUsuario);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado')),
        );
        await _refresh();
      }
    } catch (e) {
      if (context.mounted) {
        String errorMsg = 'Error al eliminar: $e';
        if (e.toString().contains('foreign key') || e.toString().contains('organizador')) {
          errorMsg = 'No se puede eliminar: este usuario tiene eventos asociados';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  final String nombre;
  final String rol;
  final String correo;
  final String foto;
  final VoidCallback? onDelete;

  const _UserCard({
    required this.nombre,
    required this.rol,
    required this.correo,
    required this.foto,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: _avatar(foto),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$rol · $correo'),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(100, 100, 0, 0),
              items: [
                PopupMenuItem(
                  onTap: onDelete,
                  child: const Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _avatar(String fotoUrl) {
    if (fotoUrl.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person));
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(fotoUrl),
      onBackgroundImageError: (_, __) {},
      child: const SizedBox.shrink(),
    );
  }
}

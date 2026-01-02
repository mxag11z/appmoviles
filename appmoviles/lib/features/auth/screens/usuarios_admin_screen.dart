import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuariosAdminContent extends StatefulWidget {
  const UsuariosAdminContent({super.key});

  @override
  State<UsuariosAdminContent> createState() => _UsuariosAdminContentState();
}

class _UsuariosAdminContentState extends State<UsuariosAdminContent> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _usersFuture;
  Map<int, String> _roleCatalog = {};

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
    _ensureRoleCatalog();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    // Selecciona solo columnas existentes para evitar errores de Postgrest.
    final selectStr = 'id_usuario, nombre, ap_paterno, ap_materno, email, rolfk, foto, activo';
    try {
      debugPrint('Executing select on usuario: $selectStr');
      final res = await _supabase.from('usuario').select(selectStr).order('nombre');
      final users = List<Map<String, dynamic>>.from(res);

      // Collect unique role ids (rolfk) to fetch their names in batch
      final Set<int> roleIds = {};
      for (final u in users) {
        final r = u['rolfk'];
        if (r != null) {
          try {
            roleIds.add(int.parse(r.toString()));
          } catch (_) {}
        }
      }

      Map<int, String> roleNames = {};
      if (roleIds.isNotEmpty) {
        try {
          final idsStr = roleIds.toList().join(',');
          final rolesResp = await _supabase
              .from('roldeusuario')
              .select('idrol, nombrerol')
              .filter('idrol', 'in', '($idsStr)');
          for (final r in List<Map<String, dynamic>>.from(rolesResp ?? [])) {
            try {
              final id = int.parse(r['idrol'].toString());
              roleNames[id] = (r['nombrerol'] ?? '').toString();
            } catch (_) {}
          }
        } catch (err) {
          debugPrint('Could not fetch role names: $err');
        }
      }

      for (final u in users) {
        final r = u['rolfk'];
        String? rn;
        if (r != null) {
          try {
            final id = int.parse(r.toString());
            rn = roleNames[id];
          } catch (_) {}
        }
        if (rn != null && rn.isNotEmpty) {
          u['rolnombre'] = rn;
        }
      }

      return users;
    } catch (e, st) {
      debugPrint('Error in _fetchUsers: $e\n$st');
      rethrow;
    }
  }

  bool? _getActive(Map<String, dynamic> u) {
    final a = u['activo'];
    if (a is bool) return a;
    if (a != null) {
      final s = a.toString().toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    final e = u['estado']; // podría no existir en tu esquema
    if (e != null) {
      final s = e.toString().toLowerCase();
      if (s == 'activo' || s == 'active' || s == '1') return true;
      if (s == 'bloqueado' || s == 'blocked' || s == 'inactivo' || s == 'inactive' || s == '0') return false;
    }
    return null;
  }

  Future<void> _toggleUserState(Map<String, dynamic> user) async {
    final idUsuario = user['id_usuario']?.toString() ?? '';
    if (idUsuario.isEmpty) return;
    final active = _getActive(user) ?? true; // default true
    debugPrint('🔄 Toggling user $idUsuario, current active=$active, new active=${!active}');
    try {
      if (user.containsKey('activo')) {
        debugPrint('✏️ Updating activo=$active to ${!active} for id=$idUsuario');
        final result = await _supabase.from('usuario').update({'activo': !active}).eq('id_usuario', idUsuario).select();
        debugPrint('✅ Update response: $result');
      } else if (user.containsKey('estado')) {
        debugPrint('✏️ Updating estado column...');
        final result = await _supabase
            .from('usuario')
            .update({'estado': active ? 'bloqueado' : 'activo'})
            .eq('id_usuario', idUsuario).select();
        debugPrint('✅ Update response: $result');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tu tabla usuario no tiene columnas estado/activo. Agrega una para poder bloquear/activar.')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(active ? 'Usuario bloqueado' : 'Usuario desbloqueado')),
      );
      debugPrint('🔄 Calling refresh...');
      await _refresh();
      debugPrint('✅ Refresh complete');
    } catch (e, st) {
      debugPrint('❌ Error toggling user: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estado: $e')),
      );
    }
  }

  Future<void> _ensureRoleCatalog() async {
    if (_roleCatalog.isNotEmpty) return;
    try {
      final rolesResp = await _supabase
          .from('roldeusuario')
          .select('idrol, nombrerol')
          .order('idrol');
      final list = List<Map<String, dynamic>>.from(rolesResp ?? []);
      _roleCatalog = {
        for (final r in list)
          int.parse(r['idrol'].toString()): (r['nombrerol'] ?? '').toString(),
      };
    } catch (e) {
      debugPrint('Could not load role catalog: $e');
    }
  }

  Future<void> _changeUserRole(Map<String, dynamic> user) async {
    await _ensureRoleCatalog();
    final idUsuario = user['id_usuario']?.toString() ?? '';
    final current = int.tryParse(user['rolfk']?.toString() ?? '') ?? _roleCatalog.keys.firstOrNull ?? 1;
    int selected = current;

    if (idUsuario.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cambiar rol', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selected,
                items: _roleCatalog.entries
                    .map((e) => DropdownMenuItem<int>(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => selected = v ?? selected,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Rol'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Bloquear'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () async {
                      try {
                        await _supabase
                            .from('usuario')
                            .update({'rolfk': selected})
                            .eq('id_usuario', idUsuario);
                        if (mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rol actualizado')));
                          await _refresh();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar rol: $e')));
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
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
              final roleName = (u['rolnombre'] ?? '').toString();
              final rol = roleName.isNotEmpty ? roleName : (u['rolfk']?.toString() ?? '—');
              final correo = u['email'] ?? '—';
              final foto = (u['foto'] ?? '').toString().trim();
              final isActive = _getActive(u);
              final estadoLabel = isActive == null ? '—' : (isActive ? 'Activo' : 'Bloqueado');
              final estadoBg = isActive == null
                  ? Colors.grey.shade200
                  : (isActive ? Colors.green.shade50 : Colors.red.shade50);
              final estadoFg = isActive == null
                  ? Colors.grey.shade700
                  : (isActive ? Colors.green.shade700 : Colors.red.shade700);
              final toggleText = (isActive ?? true) ? 'Bloquear' : 'Desbloquear';

              return _UserCard(
                nombre: fullName.isEmpty ? 'Sin nombre' : fullName,
                rol: rol,
                correo: correo,
                foto: foto,
                onMore: () => _changeUserRole(u),
                estadoLabel: estadoLabel,
                estadoBg: estadoBg,
                estadoFg: estadoFg,
                onToggleEstado: () => _toggleUserState(u),
                toggleText: toggleText,
              );
            },
          );
        },
      ),
    );
  }
}

class UsuariosAdminScreen extends StatelessWidget {
  const UsuariosAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: const UsuariosAdminContent(),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String nombre;
  final String rol;
  final String correo;
  final String foto;
  final VoidCallback? onMore;
  final String? estadoLabel;
  final Color? estadoBg;
  final Color? estadoFg;
  final VoidCallback? onToggleEstado;
  final String? toggleText;

  const _UserCard({
    required this.nombre,
    required this.rol,
    required this.correo,
    required this.foto,
    this.onMore,
    this.estadoLabel,
    this.estadoBg,
    this.estadoFg,
    this.onToggleEstado,
    this.toggleText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x14000000))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(foto),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                      IconButton(onPressed: onMore, icon: const Icon(Icons.more_vert)),                     
                      
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(999)),
                      child: Text(rol.toString(), style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    if (estadoLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: estadoBg ?? Colors.grey.shade200, borderRadius: BorderRadius.circular(999)),
                        child: Text(
                          estadoLabel!,
                          style: TextStyle(color: estadoFg ?? Colors.grey.shade700, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(correo, style: TextStyle(color: Colors.grey.shade700), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: onMore,
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        child: const Text('Cambiar rol', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: onToggleEstado,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E60A8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        child: Text(toggleText ?? 'Bloquear', style: const TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: profile image (larger)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: _profileImage(foto),
            ),
          ),
        ],
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

  Widget _profileImage(String url) {
    if (url.trim().isEmpty) {
      return Container(
        color: const Color(0xFFE5E7EB),
        child: const Icon(Icons.person, size: 36),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE5E7EB), child: const Icon(Icons.broken_image_outlined)),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}

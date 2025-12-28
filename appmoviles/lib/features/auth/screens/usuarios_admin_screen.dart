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
              .from('roldesuario')
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

              return _UserCard(
                nombre: fullName.isEmpty ? 'Sin nombre' : fullName,
                rol: rol,
                correo: correo,
                foto: foto,
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

  const _UserCard({
    required this.nombre,
    required this.rol,
    required this.correo,
    required this.foto,
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
                      IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),                     
                      
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(correo, style: TextStyle(color: Colors.grey.shade700), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                      child: const Text('Ver'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E60A8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                      child: const Text('Bloquear'),
                    ),
                  ],
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

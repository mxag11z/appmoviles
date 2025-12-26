import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuariosAdminScreen extends StatefulWidget {
  const UsuariosAdminScreen({super.key});

  @override
  State<UsuariosAdminScreen> createState() => _UsuariosAdminScreenState();
}

class _UsuariosAdminScreenState extends State<UsuariosAdminScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final res = await _supabase
        .from('usuario')
        .select('id_usuario, nombre, ap_paterno, ap_materno, email, rol, foto')
        .order('nombre');
    return List<Map<String, dynamic>>.from(res);
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
                final rol = u['rol'] ?? '—';
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
      ),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: _avatar(foto),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$rol · $correo'),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // acciones: editar, bloquear, resetear contraseña, etc.
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

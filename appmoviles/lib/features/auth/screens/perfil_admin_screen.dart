import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilAdminScreen extends StatefulWidget {
  const PerfilAdminScreen({super.key});

  @override
  State<PerfilAdminScreen> createState() => _PerfilAdminScreenState();
}

class _PerfilAdminScreenState extends State<PerfilAdminScreen> {
  final _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>?> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = _fetchPerfil();
  }

  Future<Map<String, dynamic>?> _fetchPerfil() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final res = await _supabase
        .from('usuario')
        .select(
          '''
          id_usuario,
          nombre,
          ap_paterno,
          ap_materno,
          email,
          foto,
          rolfk,
          rolesusuario(nombrerol)
          ''',
        )
        .eq('id_usuario', user.id)
        .maybeSingle();

    if (res == null) return null;
    return Map<String, dynamic>.from(res);
  }

  Future<void> _refresh() async {
    setState(() {
      _perfilFuture = _fetchPerfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _perfilFuture,
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
            final perfil = snapshot.data;
            if (perfil == null) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No se encontro perfil.')),
                ],
              );
            }

            final nombre = (perfil['nombre'] ?? '').toString();
            final apPat = (perfil['ap_paterno'] ?? '').toString();
            final apMat = (perfil['ap_materno'] ?? '').toString();
            final fullName = [nombre, apPat, apMat]
                .where((x) => x.trim().isNotEmpty)
                .join(' ');

            final correo = (perfil['email'] ?? '').toString();
            final foto = (perfil['foto'] ?? '').toString().trim();
            final rolNombre = (perfil['rolesusuario']?['nombrerol'] ?? '').toString();
            final rolId = perfil['rolfk'];
            final rolDisplay = rolNombre.isNotEmpty
                ? rolNombre
                : (rolId == null ? 'Sin rol' : 'Rol #$rolId');

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: foto.isEmpty ? null : NetworkImage(foto),
                    child: foto.isEmpty ? const Icon(Icons.person, size: 48) : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    fullName.isEmpty ? 'Sin nombre' : fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    rolDisplay,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Correo'),
                    subtitle: Text(correo.isEmpty ? 'Sin correo' : correo),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Rol'),
                    subtitle: Text(rolDisplay),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    // Navegar a edicion de perfil.
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar perfil'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await _supabase.auth.signOut();
                    if (mounted) {
                      // Redirigir a login si usas GoRouter/Navigator.
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesion'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

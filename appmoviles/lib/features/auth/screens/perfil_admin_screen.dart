import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class PerfilAdminContent extends StatefulWidget {
  const PerfilAdminContent({super.key});

  @override
  State<PerfilAdminContent> createState() => _PerfilAdminContentState();
}

class _PerfilAdminContentState extends State<PerfilAdminContent> {
  final _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>?> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = _fetchPerfil();
  }

  Future<Map<String, dynamic>?> _fetchPerfil() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No hay usuario autenticado');
      return null;
    }

    debugPrint('🔍 Buscando perfil para user.id=${user.id}, email=${user.email}');

    // Buscar por id_usuario o por email en una sola consulta
    final email = (user.email ?? '').trim();
    
    try {
      final res = await _supabase
          .from('usuario')
          .select('id_usuario, nombre, ap_paterno, ap_materno, email, foto, rolfk')
          .or('id_usuario.eq.${user.id},email.eq.$email')
          .limit(1)
          .maybeSingle();

      debugPrint('📦 Resultado query: $res');

      if (res == null) {
        debugPrint('❌ No se encontró usuario en BD');
        return null;
      }

      final perfil = Map<String, dynamic>.from(res);
      try {
        final rfk = perfil['rolfk'];
        if (rfk != null) {
          final id = int.tryParse(rfk.toString());
          if (id != null) {
            // Tabla correcta: roldeusuario (con "e")
            final roleResp = await _supabase
                .from('roldeusuario')
                .select('idrol, nombrerol')
                .eq('idrol', id)
                .maybeSingle();
            if (roleResp != null) {
              perfil['rolnombre'] = roleResp['nombrerol'] ?? '';
            }
          }
        }
      } catch (e) {
        debugPrint('Could not fetch role name for perfil: $e');
      }

      debugPrint('✅ Perfil encontrado: ${perfil['nombre']}');
      return perfil;
    } catch (e, st) {
      debugPrint('❌ Error en _fetchPerfil: $e\n$st');
      rethrow;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _perfilFuture = _fetchPerfil();
    });
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _supabase.auth.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Future<void> _editarPerfil(BuildContext context, Map<String, dynamic> perfil) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return _EditarPerfilForm(
          perfil: perfil,
          supabase: _supabase,
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
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
          final rolNombre = (perfil['rolnombre'] ?? '').toString();
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
                onPressed: () => _editarPerfil(context, perfil),
                icon: const Icon(Icons.edit),
                label: const Text('Editar perfil'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _cerrarSesion(context),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesion'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EditarPerfilForm extends StatefulWidget {
  final Map<String, dynamic> perfil;
  final SupabaseClient supabase;

  const _EditarPerfilForm({
    required this.perfil,
    required this.supabase,
  });

  @override
  State<_EditarPerfilForm> createState() => _EditarPerfilFormState();
}

class _EditarPerfilFormState extends State<_EditarPerfilForm> {
  late final TextEditingController nombreCtrl;
  late final TextEditingController apPatCtrl;
  late final TextEditingController apMatCtrl;

  @override
  void initState() {
    super.initState();
    nombreCtrl = TextEditingController(text: widget.perfil['nombre'] ?? '');
    apPatCtrl = TextEditingController(text: widget.perfil['ap_paterno'] ?? '');
    apMatCtrl = TextEditingController(text: widget.perfil['ap_materno'] ?? '');
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    apPatCtrl.dispose();
    apMatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Editar perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: nombreCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: apPatCtrl,
            decoration: const InputDecoration(
              labelText: 'Apellido Paterno',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: apMatCtrl,
            decoration: const InputDecoration(
              labelText: 'Apellido Materno',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    try {
                      final idUsuario = widget.perfil['id_usuario']?.toString();
                      if (idUsuario == null) throw 'ID de usuario no encontrado';

                      await widget.supabase.from('usuario').update({
                        'nombre': nombreCtrl.text.trim(),
                        'ap_paterno': apPatCtrl.text.trim(),
                        'ap_materno': apMatCtrl.text.trim(),
                      }).eq('id_usuario', idUsuario);

                      if (mounted) {
                        Navigator.of(context).pop(true);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PerfilAdminScreen extends StatelessWidget {
  const PerfilAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const PerfilAdminContent(),
    );
  }
}

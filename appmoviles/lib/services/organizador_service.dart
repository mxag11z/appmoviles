import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizadorService {
  final SupabaseClient supabase;

  OrganizadorService(this.supabase);

  /// Obtiene el nombre completo del organizador por su ID
  Future<String?> fetchOrganizadorName(String organizadorId) async {
    if (organizadorId.isEmpty) return null;

    final data = await supabase
        .from('usuario')
        .select('nombre, ap_paterno, ap_materno')
        .eq('id_usuario', organizadorId)
        .maybeSingle();

    if (data == null) return null;

    final nombre = data['nombre'] ?? '';
    final apPaterno = data['ap_paterno'] ?? '';
    final apMaterno = data['ap_materno'] ?? '';

    return '$nombre $apPaterno $apMaterno'.trim();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:appmoviles/data/models/usuario_model.dart';

class UserService {
  final supabase = Supabase.instance.client;


  //Metodo para actualizar la foto de perfil la str 
  Future updateFotoPerfil(String url) async {
    final userId = supabase.auth.currentUser!.id; //null check operator
    await supabase
        .from("Usuario")
        .update({"foto": url})
        .eq("id_usuario", userId); 
  }

  Future<Usuario?> getCurrentUsuario() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('usuario')
        .select('*')
        .eq('id_usuario', user.id)
        .maybeSingle();

    if (response == null) return null;

    return Usuario.fromMap(response);
  }

}

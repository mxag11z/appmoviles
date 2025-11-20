import 'package:supabase_flutter/supabase_flutter.dart';

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
}

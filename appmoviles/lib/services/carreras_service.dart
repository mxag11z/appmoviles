import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:appmoviles/data/models/carrera_model.dart';

class CarrerasService {
  final supabase = Supabase.instance.client;

  // Obtener todas las carreras
  Future<List<CarreraModel>?> fetchCarreras() async {
    try {
      final resp = await supabase.from('carrera').select().order('carrera');
      print('fetchCarreras response: $resp');
      if (resp == null) return [];
      final List data = resp as List;
      return data.map((e) => CarreraModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      return null;
    }
  }

  // Obtener una carrera por id
  Future<CarreraModel?> fetchCarreraById(String id) async {
    try {
      final resp = await supabase.from('carrera').select().eq('id_carrera', id).single();
      if (resp == null) return null;
      return CarreraModel.fromMap(Map<String, dynamic>.from(resp));
    } catch (e) {
      return null;
    }
  }

  // Crear una nueva carrera.
  Future<String?> createCarrera(CarreraModel carrera) async {
    try {
      await supabase.from('carrera').insert(carrera.toMap());
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

}
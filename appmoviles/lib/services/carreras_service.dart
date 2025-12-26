import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:appmoviles/data/models/carrera_model.dart';

class CarrerasService {
  final SupabaseClient supabase;

  CarrerasService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  /// Obtener todas las carreras (retorna lista vacía si no hay datos)
  Future<List<CarreraModel>> fetchCarreras() async {
    try {
      final resp = await supabase.from('carrera').select().order('carrera');
      debugPrint('fetchCarreras response: $resp');
      if (resp == null) return [];
      final List data = resp as List;
      return data
          .map((e) => CarreraModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException fetchCarreras: ${e.message}');
      return [];
    } catch (e, st) {
      debugPrint('Error fetchCarreras: $e\n$st');
      return [];
    }
  }

  /// Obtener una carrera por id (retorna null si no existe)
  Future<CarreraModel?> fetchCarreraById(String id) async {
    try {
      final resp = await supabase
          .from('carrera')
          .select()
          .eq('id_carrera', id)
          .maybeSingle();
      debugPrint('fetchCarreraById response: $resp');
      if (resp == null) return null;
      return CarreraModel.fromMap(Map<String, dynamic>.from(resp));
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException fetchCarreraById: ${e.message}');
      return null;
    } catch (e, st) {
      debugPrint('Error fetchCarreraById: $e\n$st');
      return null;
    }
  }

  /// Crear una nueva carrera. Retorna null si éxito, o mensaje de error.
  Future<String?> createCarrera(CarreraModel carrera) async {
    try {
      final resp = await supabase.from('carrera').insert(carrera.toMap()).select();
      debugPrint('createCarrera response: $resp');
      return null;
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException createCarrera: ${e.message}');
      return e.message;
    } catch (e, st) {
      debugPrint('Error createCarrera: $e\n$st');
      return e.toString();
    }
  }
}
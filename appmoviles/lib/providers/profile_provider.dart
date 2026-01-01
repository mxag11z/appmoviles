import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/profile_service.dart';
import '../services/notification_service.dart';
import '../data/models/usuario_model.dart';
import '../data/models/student_model.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(Supabase.instance.client);
});

/// Estado combinado del perfil
class ProfileState {
  final Usuario? usuario;
  final StudentModel? estudiante;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.usuario,
    this.estudiante,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    Usuario? usuario,
    StudentModel? estudiante,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      usuario: usuario ?? this.usuario,
      estudiante: estudiante ?? this.estudiante,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  String get nombreCompleto {
    if (usuario == null) return '';
    return '${usuario!.nombre} ${usuario!.apellidoPaterno} ${usuario!.apellidoMaterno}';
  }
}

/// Provider principal del perfil
final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    return _fetchProfile();
  }

  Future<ProfileState> _fetchProfile() async {
    final service = ref.read(profileServiceProvider);
    final usuario = await service.getCurrentUsuario();
    final estudiante = await service.getCurrentEstudiante();

    return ProfileState(
      usuario: usuario,
      estudiante: estudiante,
    );
  }

  /// Actualizar nombre
  Future<bool> updateNombre({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
  }) async {
    try {
      state = AsyncData(state.value!.copyWith(isLoading: true));

      final service = ref.read(profileServiceProvider);
      await service.updateNombre(
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
      );

      // Refrescar el perfil
      state = AsyncData(await _fetchProfile());
      return true;
    } catch (e) {
      state = AsyncData(state.value!.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  /// Actualizar intereses
  Future<bool> updateIntereses(List<String> intereses) async {
    try {
      state = AsyncData(state.value!.copyWith(isLoading: true));

      final service = ref.read(profileServiceProvider);
      await service.updateIntereses(intereses);

      // Refrescar el perfil
      state = AsyncData(await _fetchProfile());
      return true;
    } catch (e) {
      state = AsyncData(state.value!.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  /// Actualizar foto de perfil
  Future<bool> updateFoto(File file) async {
    try {
      state = AsyncData(state.value!.copyWith(isLoading: true));

      final service = ref.read(profileServiceProvider);
      await service.updateFotoPerfil(file);

      // Refrescar el perfil
      state = AsyncData(await _fetchProfile());
      return true;
    } catch (e) {
      print('ERROR al actualizar foto: $e');
      state = AsyncData(state.value!.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    // Limpiar token de notificaciones
    await NotificationService().removeToken();

    final service = ref.read(profileServiceProvider);
    await service.signOut();
  }

  /// Refrescar perfil
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchProfile());
  }
}

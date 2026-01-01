import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/organizador_service.dart';

final organizadorServiceProvider = Provider<OrganizadorService>((ref) {
  return OrganizadorService(Supabase.instance.client);
});

/// Provider que obtiene el nombre del organizador dado su ID
final organizadorNameProvider =
    FutureProvider.family<String?, String>((ref, organizadorId) async {
  final service = ref.read(organizadorServiceProvider);
  return service.fetchOrganizadorName(organizadorId);
});

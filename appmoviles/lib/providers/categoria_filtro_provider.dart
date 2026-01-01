import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriaFiltroNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setCategoria(String? value) => state = value;
  void clear() => state = null;
}

final categoriaFiltroProvider =
    NotifierProvider<CategoriaFiltroNotifier, String?>(
      CategoriaFiltroNotifier.new,
    );
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UbicacionFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setUbicacion(String? value) => state = value;
  void clear() => state = null;
}

final ubicacionFilterProvider =
    NotifierProvider<UbicacionFilterNotifier, String?>(
  UbicacionFilterNotifier.new,
);

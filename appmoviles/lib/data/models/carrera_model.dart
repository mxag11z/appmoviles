class CarreraModel {
  final int idCarrera;
  final String carrera;

  CarreraModel({
    required this.idCarrera,
    required this.carrera,
  });

  /// JSON → Modelo
  factory CarreraModel.fromMap(Map<String, dynamic> map) {
    return CarreraModel(
      idCarrera: map['id_carrera'],
      carrera: map['carrera'],
    );
  }

  /// Modelo → JSON 
  Map<String, dynamic> toMap() {
    return {
      'id_carrera': idCarrera,
      'carrera': carrera,
    };
  }
}

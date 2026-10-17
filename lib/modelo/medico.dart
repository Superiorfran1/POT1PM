class Medico {
  final String id;
  final String nombre;
  final String especialidad;

  Medico({required this.id, required this.nombre, required this.especialidad});

  // En Firebase el id es la clave del nodo, no va dentro del JSON.
  factory Medico.fromJson(String id, Map<String, dynamic> json) => Medico(
        id: id,
        nombre: json['nombre'],
        especialidad: json['especialidad'],
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'especialidad': especialidad,
      };

  @override
  String toString() => '''Nombre del médico: $nombre
Especialidad: $especialidad''';
}

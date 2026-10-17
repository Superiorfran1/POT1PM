class Paciente {
  final int numHistoria;
  final String dni;
  final String nombre;
  final String apellidos;
  final String sintomas;

  Paciente({
    required this.numHistoria,
    required this.dni,
    required this.nombre,
    required this.apellidos,
    required this.sintomas,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) => Paciente(
        numHistoria: json['numHistoria'],
        dni: json['dni'],
        nombre: json['nombre'],
        apellidos: json['apellidos'],
        sintomas: json['sintomas'],
      );

  Map<String, dynamic> toJson() => {
        'numHistoria': numHistoria,
        'dni': dni,
        'nombre': nombre,
        'apellidos': apellidos,
        'sintomas': sintomas,
      };

  @override
  String toString() => '''****** Datos de paciente ******
Nombre del paciente: $nombre $apellidos
Historia del paciente: $numHistoria
Síntomas del paciente: $sintomas''';
}

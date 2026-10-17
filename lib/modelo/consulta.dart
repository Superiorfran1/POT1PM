import 'medico.dart';
import 'paciente.dart';

class Consulta {
  final int numero;
  final Medico medico;
  Paciente? paciente;
  bool libre;

  Consulta({
    required this.numero,
    required this.medico,
    this.paciente,
    this.libre = true,
  });

  // El médico no viene en el JSON de la consulta: se lo pasa quien la lee.
  factory Consulta.fromJson(Map<String, dynamic> json, Medico medico) =>
      Consulta(
        numero: json['numero'],
        medico: medico,
        paciente:
            json['paciente'] == null ? null : Paciente.fromJson(json['paciente']),
        libre: json['libre'],
      );

  // Si paciente es null, Firebase simplemente no guarda esa clave.
  Map<String, dynamic> toJson() => {
        'numero': numero,
        'medicoId': medico.id,
        'libre': libre,
        'paciente': paciente?.toJson(),
      };

  void ocupar(Paciente nuevo) {
    paciente = nuevo;
    libre = false;
  }

  void liberar() {
    paciente = null;
    libre = true;
  }

  @override
  String toString() {
    final datosPaciente = libre
        ? 'Paciente: consulta libre'
        : 'Paciente: ${paciente!.nombre} ${paciente!.apellidos}\nNum_historia: ${paciente!.numHistoria}';
    return '''***** Consulta: $numero ***********
$medico
$datosPaciente''';
  }
}

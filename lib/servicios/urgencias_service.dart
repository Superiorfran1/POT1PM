import 'package:urgencias/modelo/consulta.dart';
import 'package:urgencias/modelo/medico.dart';
import 'package:urgencias/modelo/paciente.dart';
import 'package:urgencias/servicios/firebase_service.dart';

/// La lógica de las urgencias. No sabe nada de teclado ni de HTTP.
class UrgenciasService {
  final FirebaseService _firebase = FirebaseService();

  /// Descarga los médicos y deja las consultas preparadas en Firebase.
  Future<List<Medico>> arranque() async {
    final medicos = await _firebase.getMedicos();
    await _firebase.getConsultas();
    return medicos;
  }

  Future<String> admitir({
    required String dni,
    required String nombre,
    required String apellidos,
    required String sintomas,
  }) async {
    final paciente = Paciente(
      numHistoria: await _firebase.generaNumHistoria(),
      dni: dni,
      nombre: nombre,
      apellidos: apellidos,
      sintomas: sintomas,
    );
    await _firebase.registraPaciente(paciente);

    final consultas = await _firebase.getConsultas();
    for (final consulta in consultas) {
      if (consulta.libre) {
        consulta.ocupar(paciente);
        await _firebase.guardaConsulta(consulta);
        return 'Se le ha asignado la consulta ${consulta.numero}\n'
            'Le atenderá ${consulta.medico.nombre}';
      }
    }

    final cola = await _firebase.getCola();
    cola.add(paciente);
    await _firebase.guardaCola(cola);
    return 'No hay médicos libres. $nombre entra en la cola (posición ${cola.length})';
  }

  Future<String> liberar(int numero) async {
    final consultas = await _firebase.getConsultas();
    if (numero < 1 || numero > consultas.length) {
      return 'La consulta $numero no existe';
    }

    final consulta = consultas[numero - 1];
    if (consulta.libre) {
      return 'La consulta $numero ya estaba libre';
    }

    consulta.liberar();
    final cola = await _firebase.getCola();

    if (cola.isEmpty) {
      await _firebase.guardaConsulta(consulta);
      return 'La consulta $numero ha quedado libre';
    }

    final siguiente = cola.first;
    cola.remove(siguiente);
    consulta.ocupar(siguiente);

    // Primero la consulta y después la cola: si algo falla entre las dos
    // escrituras, el paciente aparece duplicado, pero nunca se pierde.
    await _firebase.guardaConsulta(consulta);
    await _firebase.guardaCola(cola);

    return 'El paciente: ${siguiente.nombre} ${siguiente.apellidos} ya puede pasar\n'
        'Se le ha asignado la consulta $numero ya puede pasar\n'
        'Le atenderá ${consulta.medico.nombre}';
  }

  Future<List<Paciente>> verCola() => _firebase.getCola();

  Future<List<Consulta>> verConsultas() => _firebase.getConsultas();
}

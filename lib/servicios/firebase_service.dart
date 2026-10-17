import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:urgencias/modelo/consulta.dart';
import 'package:urgencias/modelo/medico.dart';
import 'package:urgencias/modelo/paciente.dart';

// Cambia esto por la URL de TU base de datos (sin https://)
const _baseUrl = 'urgencias-ddc02-default-rtdb.europe-west1.firebasedatabase.app';

/// Todas las llamadas HTTP a Firebase viven aquí. Nada se guarda en memoria.
class FirebaseService {
  // ---------- Utilidades privadas ----------

  Future<dynamic> _get(String ruta) async {
    final url = Uri.https(_baseUrl, ruta);
    final respuesta = await http.get(url);
    if (respuesta.statusCode != 200) {
      throw Exception('Firebase respondió ${respuesta.statusCode} al leer $ruta');
    }
    return jsonDecode(respuesta.body); // un nodo vacío devuelve null
  }

  Future<void> _put(String ruta, dynamic dato) async {
    final url = Uri.https(_baseUrl, ruta);
    final respuesta = await http.put(url, body: jsonEncode(dato));
    if (respuesta.statusCode != 200) {
      throw Exception('Firebase respondió ${respuesta.statusCode} al escribir $ruta');
    }
  }

  // ---------- Médicos ----------

  Future<List<Medico>> getMedicos() async {
    final datos = await _get('/medicos.json');
    if (datos == null) {
      throw Exception('No hay médicos en Firebase (importa medicos_seed.json)');
    }
    final Map<String, dynamic> mapa = datos;
    return mapa.entries.map((e) => Medico.fromJson(e.key, e.value)).toList();
  }

  // ---------- Consultas ----------

  /// Una consulta por médico. Si es la primera vez y no existen, las crea libres.
  Future<List<Consulta>> getConsultas() async {
    final medicos = await getMedicos();
    final datos = await _get('/consultas.json');
    final Map<String, dynamic> guardadas = datos == null ? {} : datos;

    final consultas = <Consulta>[];
    for (var i = 0; i < medicos.length; i++) {
      final clave = 'c${i + 1}';
      Consulta consulta;
      if (guardadas[clave] == null) {
        consulta = Consulta(numero: i + 1, medico: medicos[i]);
        await guardaConsulta(consulta);
      } else {
        consulta = Consulta.fromJson(guardadas[clave], medicos[i]);
      }
      consultas.add(consulta);
    }
    return consultas;
  }

  Future<void> guardaConsulta(Consulta consulta) async {
    await _put('/consultas/c${consulta.numero}.json', consulta.toJson());
  }

  // ---------- Cola de espera ----------

  Future<List<Paciente>> getCola() async {
    final datos = await _get('/cola.json');
    if (datos == null) return [];
    final List<dynamic> lista = datos;
    return lista.map((p) => Paciente.fromJson(p)).toList();
  }

  /// Reescribe la cola entera. Una lista vacía borra el nodo en Firebase.
  Future<void> guardaCola(List<Paciente> cola) async {
    await _put('/cola.json', cola.map((p) => p.toJson()).toList());
  }

  // ---------- Pacientes registrados ----------

  /// Aquí se garantiza que numHistoria no se repite: se mira en el registro
  /// de TODOS los pacientes admitidos (estén en consulta, en cola o ya atendidos).
  Future<int> generaNumHistoria() async {
    final datos = await _get('/pacientes.json');
    final Map<String, dynamic> registrados = datos == null ? {} : datos;

    int numero;
    do {
      numero = Random().nextInt(10000) + 1; // de 1 a 10000
    } while (registrados['p$numero'] != null);
    return numero;
  }

  // La clave lleva una "p" delante: con claves 1, 2, 3... Firebase devolvería
  // una lista en vez de un mapa y se rompería el parseo.
  Future<void> registraPaciente(Paciente paciente) async {
    await _put('/pacientes/p${paciente.numHistoria}.json', paciente.toJson());
  }
}

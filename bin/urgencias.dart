import 'dart:io';
import 'package:urgencias/servicios/urgencias_service.dart';

// Solo menú y teclado: ni una llamada HTTP aquí.

String leerTexto(String pregunta) {
  String texto = '';
  while (texto.isEmpty) {
    stdout.write(pregunta);
    texto = stdin.readLineSync()!.trim();
  }
  return texto;
}

int leerEntero(String pregunta) {
  while (true) {
    stdout.write(pregunta);
    try {
      return int.parse(stdin.readLineSync()!);
    } catch (e) {
      print('Eso no es un número, prueba otra vez.');
    }
  }
}

Future<void> admision(UrgenciasService servicio) async {
  final dni = leerTexto('DNI: ');
  final nombre = leerTexto('Nombre: ');
  final apellidos = leerTexto('Apellidos: ');
  final sintomas = leerTexto('Síntomas: ');
  print(await servicio.admitir(
    dni: dni,
    nombre: nombre,
    apellidos: apellidos,
    sintomas: sintomas,
  ));
}

Future<void> liberarConsulta(UrgenciasService servicio) async {
  final numero =
      leerEntero('Introduzca el número de consulta que ha quedado liberada: ');
  print(await servicio.liberar(numero));
}

Future<void> verCola(UrgenciasService servicio) async {
  final cola = await servicio.verCola();
  print('Ahora mismo hay ${cola.length} pacientes esperando');
  for (var i = 0; i < cola.length; i++) {
    print('==== Paciente ${i + 1} en la cola ====');
    print(cola[i]);
  }
}

Future<void> verConsultas(UrgenciasService servicio) async {
  final consultas = await servicio.verConsultas();
  for (final consulta in consultas) {
    print(consulta);
  }
}

Future<void> main() async {
  final servicio = UrgenciasService();

  try {
    final medicos = await servicio.arranque();
    print('Médicos disponibles: ${medicos.length}');
  } catch (e) {
    print('No se pudo arrancar: $e');
    return;
  }

  int opcion = 0;
  do {
    print('''
1. Admisión de un paciente
2. Liberar una consulta
3. Ver la cola de espera
4. Ver el estado actual de las consultas
5. Salir''');
    opcion = leerEntero('Pulse opción: ');
    stdout.write('');
    stdout.write('');
    try {
      if (opcion == 1) {
        await admision(servicio);
      } else if (opcion == 2) {
        await liberarConsulta(servicio);
      } else if (opcion == 3) {
        await verCola(servicio);
      } else if (opcion == 4) {
        await verConsultas(servicio);
      } else if (opcion != 5) {
        print('Opción no válida');
      }
    } catch (e) {
      print('Algo salió mal: $e');
    }
    if (opcion != 5){
      stdout.write('');
      print('Pulsa ENTER para continuar...');
      stdin.readLineSync();
      stdout.write('');
      stdout.write('');
    }
  } while (opcion != 5);

  print('Hasta luego');
}

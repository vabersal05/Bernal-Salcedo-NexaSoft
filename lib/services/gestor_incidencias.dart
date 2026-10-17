import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  List<Incidencia> buscar(String texto) {
    final busqueda = texto.trim().toLowerCase(); // convertir a minusculas para que la busqueda sea insensible a mayusculas/minusculas
    if (busqueda.isEmpty) return incidencias;
    return incidencias
          .where((x) =>
                x.titulo.toLowerCase().contains(busqueda) || // convertir a minusculas para que la busqueda sea insensible a mayusculas/minusculas
                x.descripcion.toLowerCase().contains(busqueda)) // tomar en cuenta también la descripcion y no solo el titulo
            .toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    // Solución a bug-003: todo se cuenta con el mismo criterio para que corresponda
    return incidencias.where((x) => x.estado == estado).length; 
  }

  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        break;
      }
    }
    await datos.guardar(incidencias); // Solucion de bug-001: faltaba llamar al almacen local para guardar
  }

    Future<void> cambiarPrioridad(String id, String prioridad) async {
    if (!prioridades.contains(prioridad)) {
      throw ArgumentError('Prioridad no válida: $prioridad');
    }
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].prioridad = prioridad;
        break;
      }
    }
    await datos.guardar(incidencias);
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria, {String prioridad = 'Media'}) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
      prioridad: normalizarPrioridad(prioridad),
    );
    incidencias.insert(0, nuevo);
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evmcls_curso.dart';
import '../models/evmcls_tema.dart';
import '../models/evmcls_material.dart';
import '../models/evmcls_pregunta.dart';
import '../models/evmcls_evaluacion.dart';

class EVMFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ CURSOS ============
  
  // Crear curso
  Future<String> crearCurso(EVMCLSCurso curso) async {
    DocumentReference ref = await _db.collection('cursos').add(curso.toMap());
    return ref.id;
  }

  // Obtener cursos del usuario
  Stream<List<EVMCLSCurso>> obtenerCursosUsuario(String usuarioId) {
    return _db
        .collection('cursos')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
          final cursos = snapshot.docs
              .map((doc) => EVMCLSCurso.fromFirestore(doc))
              .toList();
          
          // Ordenar por fecha de creación en memoria (más reciente primero)
          cursos.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
          
          return cursos;
        });
  }

  // Actualizar curso
  Future<void> actualizarCurso(String cursoId, Map<String, dynamic> data) async {
    await _db.collection('cursos').doc(cursoId).update(data);
  }

  // Eliminar curso
  Future<void> eliminarCurso(String cursoId) async {
    // Eliminar todos los temas y contenido relacionado
    final temas = await _db
        .collection('temas')
        .where('cursoId', isEqualTo: cursoId)
        .get();
    
    for (var tema in temas.docs) {
      await eliminarTema(tema.id);
    }
    
    await _db.collection('cursos').doc(cursoId).delete();
  }

  // ============ TEMAS ============
  
  // Crear tema
  Future<String> crearTema(EVMCLSTema tema) async {
    DocumentReference ref = await _db.collection('temas').add(tema.toMap());
    return ref.id;
  }

  // Obtener temas de un curso
  Stream<List<EVMCLSTema>> obtenerTemasCurso(String cursoId) {
    return _db
        .collection('temas')
        .where('cursoId', isEqualTo: cursoId)
        .snapshots()
        .map((snapshot) {
          final temas = snapshot.docs
              .map((doc) => EVMCLSTema.fromFirestore(doc))
              .toList();
          
          // Ordenar por orden en memoria
          temas.sort((a, b) => a.orden.compareTo(b.orden));
          
          return temas;
        });
  }

  // Actualizar tema
  Future<void> actualizarTema(String temaId, Map<String, dynamic> data) async {
    await _db.collection('temas').doc(temaId).update(data);
  }

  // Eliminar tema
  Future<void> eliminarTema(String temaId) async {
    // Eliminar materiales
    final materiales = await _db
        .collection('materiales')
        .where('temaId', isEqualTo: temaId)
        .get();
    
    for (var material in materiales.docs) {
      await _db.collection('materiales').doc(material.id).delete();
    }
    
    // Eliminar preguntas
    final preguntas = await _db
        .collection('preguntas')
        .where('temaId', isEqualTo: temaId)
        .get();
    
    for (var pregunta in preguntas.docs) {
      await _db.collection('preguntas').doc(pregunta.id).delete();
    }
    
    await _db.collection('temas').doc(temaId).delete();
  }

  // ============ MATERIALES ============
  
  // Crear material
  Future<String> crearMaterial(EVMCLSMaterial material) async {
    DocumentReference ref = await _db.collection('materiales').add(material.toMap());
    return ref.id;
  }

  // Obtener materiales de un tema
  Stream<List<EVMCLSMaterial>> obtenerMaterialesTema(String temaId) {
    return _db
        .collection('materiales')
        .where('temaId', isEqualTo: temaId)
        .snapshots()
        .map((snapshot) {
          final materiales = snapshot.docs
              .map((doc) => EVMCLSMaterial.fromFirestore(doc))
              .toList();
          
          // Ordenar por fecha de subida en memoria (más reciente primero)
          materiales.sort((a, b) => b.fechaSubida.compareTo(a.fechaSubida));
          
          return materiales;
        });
  }

  // Eliminar material
  Future<void> eliminarMaterial(String materialId) async {
    await _db.collection('materiales').doc(materialId).delete();
  }

  // ============ PREGUNTAS ============
  
  // Crear pregunta
  Future<String> crearPregunta(EVMCLSPregunta pregunta) async {
    DocumentReference ref = await _db.collection('preguntas').add(pregunta.toMap());
    return ref.id;
  }

  // Obtener preguntas de un tema
  Stream<List<EVMCLSPregunta>> obtenerPreguntasTema(String temaId) {
    return _db
        .collection('preguntas')
        .where('temaId', isEqualTo: temaId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EVMCLSPregunta.fromFirestore(doc)).toList());
  }

  // Obtener preguntas aleatorias de un tema
  Future<List<EVMCLSPregunta>> obtenerPreguntasAleatorias(String temaId, int cantidad) async {
    final snapshot = await _db
        .collection('preguntas')
        .where('temaId', isEqualTo: temaId)
        .get();
    
    List<EVMCLSPregunta> preguntas = snapshot.docs
        .map((doc) => EVMCLSPregunta.fromFirestore(doc))
        .toList();
    
    preguntas.shuffle();
    return preguntas.take(cantidad).toList();
  }

  // Actualizar pregunta
  Future<void> actualizarPregunta(String preguntaId, Map<String, dynamic> data) async {
    await _db.collection('preguntas').doc(preguntaId).update(data);
  }

  // Eliminar pregunta
  Future<void> eliminarPregunta(String preguntaId) async {
    await _db.collection('preguntas').doc(preguntaId).delete();
  }

  // ============ EVALUACIONES ============
  
  // Guardar evaluación
  Future<String> guardarEvaluacion(EVMCLSEvaluacion evaluacion) async {
    DocumentReference ref = await _db.collection('evaluaciones').add(evaluacion.toMap());
    return ref.id;
  }

  // Obtener historial de evaluaciones del usuario
  Stream<List<EVMCLSEvaluacion>> obtenerHistorialEvaluaciones(String usuarioId) {
    return _db
        .collection('evaluaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
          final evaluaciones = snapshot.docs
              .map((doc) => EVMCLSEvaluacion.fromFirestore(doc))
              .toList();
          
          // Ordenar por fecha de realización en memoria (más reciente primero)
          evaluaciones.sort((a, b) => b.fechaRealizacion.compareTo(a.fechaRealizacion));
          
          return evaluaciones;
        });
  }

  // Obtener evaluaciones por tema
  Stream<List<EVMCLSEvaluacion>> obtenerEvaluacionesPorTema(String usuarioId, String temaId) {
    return _db
        .collection('evaluaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('temaId', isEqualTo: temaId)
        .snapshots()
        .map((snapshot) {
          final evaluaciones = snapshot.docs
              .map((doc) => EVMCLSEvaluacion.fromFirestore(doc))
              .toList();
          
          // Ordenar por fecha de realización en memoria (más reciente primero)
          evaluaciones.sort((a, b) => b.fechaRealizacion.compareTo(a.fechaRealizacion));
          
          return evaluaciones;
        });
  }

  // Obtener evaluaciones por curso
  Stream<List<EVMCLSEvaluacion>> obtenerEvaluacionesPorCurso(String usuarioId, String cursoId) {
    return _db
        .collection('evaluaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('cursoId', isEqualTo: cursoId)
        .snapshots()
        .map((snapshot) {
          final evaluaciones = snapshot.docs
              .map((doc) => EVMCLSEvaluacion.fromFirestore(doc))
              .toList();
          
          // Ordenar por fecha de realización en memoria (más reciente primero)
          evaluaciones.sort((a, b) => b.fechaRealizacion.compareTo(a.fechaRealizacion));
          
          return evaluaciones;
        });
  }

  // Obtener estadísticas de un curso
  Future<Map<String, dynamic>> obtenerEstadisticasCurso(String usuarioId, String cursoId) async {
    final evaluaciones = await _db
        .collection('evaluaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('cursoId', isEqualTo: cursoId)
        .get();

    if (evaluaciones.docs.isEmpty) {
      return {
        'totalEvaluaciones': 0,
        'promedioGeneral': 0.0,
        'mejorPuntaje': 0.0,
        'peorPuntaje': 0.0,
      };
    }

    List<double> porcentajes = evaluaciones.docs
        .map((doc) => (doc.data()['porcentaje'] as num).toDouble())
        .toList();

    return {
      'totalEvaluaciones': evaluaciones.docs.length,
      'promedioGeneral': porcentajes.reduce((a, b) => a + b) / porcentajes.length,
      'mejorPuntaje': porcentajes.reduce((a, b) => a > b ? a : b),
      'peorPuntaje': porcentajes.reduce((a, b) => a < b ? a : b),
    };
  }
}

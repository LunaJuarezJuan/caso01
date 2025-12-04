import 'package:cloud_firestore/cloud_firestore.dart';

class EVMCLSEvaluacion {
  final String id;
  final String usuarioId;
  final String temaId;
  final String cursoId;
  final int puntajeObtenido;
  final int puntajeTotal;
  final double porcentaje;
  final int duracionSegundos;
  final DateTime fechaRealizacion;
  final Map<String, String> respuestasUsuario; // preguntaId: respuesta

  EVMCLSEvaluacion({
    required this.id,
    required this.usuarioId,
    required this.temaId,
    required this.cursoId,
    required this.puntajeObtenido,
    required this.puntajeTotal,
    required this.porcentaje,
    required this.duracionSegundos,
    required this.fechaRealizacion,
    required this.respuestasUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'temaId': temaId,
      'cursoId': cursoId,
      'puntajeObtenido': puntajeObtenido,
      'puntajeTotal': puntajeTotal,
      'porcentaje': porcentaje,
      'duracionSegundos': duracionSegundos,
      'fechaRealizacion': Timestamp.fromDate(fechaRealizacion),
      'respuestasUsuario': respuestasUsuario,
    };
  }

  factory EVMCLSEvaluacion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EVMCLSEvaluacion(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      temaId: data['temaId'] ?? '',
      cursoId: data['cursoId'] ?? '',
      puntajeObtenido: data['puntajeObtenido'] ?? 0,
      puntajeTotal: data['puntajeTotal'] ?? 0,
      porcentaje: (data['porcentaje'] ?? 0.0).toDouble(),
      duracionSegundos: data['duracionSegundos'] ?? 0,
      fechaRealizacion: (data['fechaRealizacion'] as Timestamp).toDate(),
      respuestasUsuario: Map<String, String>.from(data['respuestasUsuario'] ?? {}),
    );
  }

  EVMCLSEvaluacion copyWith({
    String? id,
    String? usuarioId,
    String? temaId,
    String? cursoId,
    int? puntajeObtenido,
    int? puntajeTotal,
    double? porcentaje,
    int? duracionSegundos,
    DateTime? fechaRealizacion,
    Map<String, String>? respuestasUsuario,
  }) {
    return EVMCLSEvaluacion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      temaId: temaId ?? this.temaId,
      cursoId: cursoId ?? this.cursoId,
      puntajeObtenido: puntajeObtenido ?? this.puntajeObtenido,
      puntajeTotal: puntajeTotal ?? this.puntajeTotal,
      porcentaje: porcentaje ?? this.porcentaje,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      fechaRealizacion: fechaRealizacion ?? this.fechaRealizacion,
      respuestasUsuario: respuestasUsuario ?? this.respuestasUsuario,
    );
  }
}

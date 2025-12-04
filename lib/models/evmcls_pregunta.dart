import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoPregunta { seleccionMultiple, verdaderoFalso }

class EVMCLSPregunta {
  final String id;
  final String temaId;
  final String enunciado;
  final TipoPregunta tipo;
  final List<String> opciones;
  final String respuestaCorrecta;
  final DateTime fechaCreacion;

  EVMCLSPregunta({
    required this.id,
    required this.temaId,
    required this.enunciado,
    required this.tipo,
    required this.opciones,
    required this.respuestaCorrecta,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'temaId': temaId,
      'enunciado': enunciado,
      'tipo': tipo.toString().split('.').last,
      'opciones': opciones,
      'respuestaCorrecta': respuestaCorrecta,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  factory EVMCLSPregunta.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EVMCLSPregunta(
      id: doc.id,
      temaId: data['temaId'] ?? '',
      enunciado: data['enunciado'] ?? '',
      tipo: data['tipo'] == 'verdaderoFalso'
          ? TipoPregunta.verdaderoFalso
          : TipoPregunta.seleccionMultiple,
      opciones: List<String>.from(data['opciones'] ?? []),
      respuestaCorrecta: data['respuestaCorrecta'] ?? '',
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  EVMCLSPregunta copyWith({
    String? id,
    String? temaId,
    String? enunciado,
    TipoPregunta? tipo,
    List<String>? opciones,
    String? respuestaCorrecta,
    DateTime? fechaCreacion,
  }) {
    return EVMCLSPregunta(
      id: id ?? this.id,
      temaId: temaId ?? this.temaId,
      enunciado: enunciado ?? this.enunciado,
      tipo: tipo ?? this.tipo,
      opciones: opciones ?? this.opciones,
      respuestaCorrecta: respuestaCorrecta ?? this.respuestaCorrecta,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

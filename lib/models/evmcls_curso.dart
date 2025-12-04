import 'package:cloud_firestore/cloud_firestore.dart';

class EVMCLSCurso {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String usuarioId;
  final DateTime fechaCreacion;

  EVMCLSCurso({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.usuarioId,
    required this.fechaCreacion,
  });

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'usuarioId': usuarioId,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Crear desde documento de Firebase
  factory EVMCLSCurso.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EVMCLSCurso(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      categoria: data['categoria'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  // Copiar con modificaciones
  EVMCLSCurso copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? usuarioId,
    DateTime? fechaCreacion,
  }) {
    return EVMCLSCurso(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

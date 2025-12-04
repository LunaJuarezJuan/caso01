import 'package:cloud_firestore/cloud_firestore.dart';

class EVMCLSTema {
  final String id;
  final String cursoId;
  final String nombre;
  final String descripcion;
  final int orden;
  final DateTime fechaCreacion;

  EVMCLSTema({
    required this.id,
    required this.cursoId,
    required this.nombre,
    required this.descripcion,
    required this.orden,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'cursoId': cursoId,
      'nombre': nombre,
      'descripcion': descripcion,
      'orden': orden,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  factory EVMCLSTema.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EVMCLSTema(
      id: doc.id,
      cursoId: data['cursoId'] ?? '',
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      orden: data['orden'] ?? 0,
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  EVMCLSTema copyWith({
    String? id,
    String? cursoId,
    String? nombre,
    String? descripcion,
    int? orden,
    DateTime? fechaCreacion,
  }) {
    return EVMCLSTema(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      orden: orden ?? this.orden,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

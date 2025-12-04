import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoMaterial { pdf, video }

class EVMCLSMaterial {
  final String id;
  final String temaId;
  final String nombre;
  final String descripcion;
  final TipoMaterial tipo;
  final String urlArchivo; // URL de Firebase Storage
  final DateTime fechaSubida;

  EVMCLSMaterial({
    required this.id,
    required this.temaId,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.urlArchivo,
    required this.fechaSubida,
  });

  Map<String, dynamic> toMap() {
    return {
      'temaId': temaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo.toString().split('.').last,
      'urlArchivo': urlArchivo,
      'fechaSubida': Timestamp.fromDate(fechaSubida),
    };
  }

  factory EVMCLSMaterial.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EVMCLSMaterial(
      id: doc.id,
      temaId: data['temaId'] ?? '',
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      tipo: data['tipo'] == 'video' ? TipoMaterial.video : TipoMaterial.pdf,
      urlArchivo: data['urlArchivo'] ?? '',
      fechaSubida: (data['fechaSubida'] as Timestamp).toDate(),
    );
  }

  EVMCLSMaterial copyWith({
    String? id,
    String? temaId,
    String? nombre,
    String? descripcion,
    TipoMaterial? tipo,
    String? urlArchivo,
    DateTime? fechaSubida,
  }) {
    return EVMCLSMaterial(
      id: id ?? this.id,
      temaId: temaId ?? this.temaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      urlArchivo: urlArchivo ?? this.urlArchivo,
      fechaSubida: fechaSubida ?? this.fechaSubida,
    );
  }
}

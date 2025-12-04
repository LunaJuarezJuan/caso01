import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class EVMStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Subir archivo con bytes (para web) con progreso
  Future<String> subirArchivoConProgreso({
    required Uint8List bytes,
    required String nombreArchivo,
    required String carpeta,
    required Function(double) onProgress,
  }) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_$nombreArchivo';
      String path = '$carpeta/$fileName';
      
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putData(bytes);
      
      // Escuchar progreso
      uploadTask.snapshotEvents.listen((snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir archivo: $e');
    }
  }

  // Eliminar archivo por URL
  Future<void> eliminarArchivo(String url) async {
    try {
      Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar archivo: $e');
    }
  }

  // Obtener referencia de archivo
  Reference obtenerReferencia(String path) {
    return _storage.ref().child(path);
  }
}

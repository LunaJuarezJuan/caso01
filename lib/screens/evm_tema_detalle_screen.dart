import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/evmcls_curso.dart';
import '../models/evmcls_tema.dart';
import '../models/evmcls_material.dart';
import '../services/evm_firestore_service.dart';
import '../services/evm_storage_service.dart';
import 'evm_preguntas_list_screen.dart';
import 'evm_evaluacion_config_screen.dart';

class EVMTemaDetalleScreen extends StatefulWidget {
  final EVMCLSTema tema;
  final EVMCLSCurso curso;

  const EVMTemaDetalleScreen({
    super.key,
    required this.tema,
    required this.curso,
  });

  @override
  State<EVMTemaDetalleScreen> createState() => _EVMTemaDetalleScreenState();
}

class _EVMTemaDetalleScreenState extends State<EVMTemaDetalleScreen> {
  final EVMFirestoreService _firestoreService = EVMFirestoreService();
  final EVMStorageService _storageService = EVMStorageService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadingFileName = '';

  Future<void> _subirPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
          _uploadingFileName = result.files.single.name;
        });

        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        // Subir PDF con seguimiento de progreso
        final urlArchivo = await _storageService.subirArchivoConProgreso(
          bytes: bytes,
          nombreArchivo: fileName,
          carpeta: 'materiales/${widget.tema.id}/pdfs',
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );

        // Crear material en Firestore
        final material = EVMCLSMaterial(
          id: '',
          temaId: widget.tema.id,
          nombre: fileName.replaceAll('.pdf', ''),
          descripcion: '',
          tipo: TipoMaterial.pdf,
          urlArchivo: urlArchivo,
          fechaSubida: DateTime.now(),
        );

        await _firestoreService.crearMaterial(material);

        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadProgress = 0.0;
            _uploadingFileName = '';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF subido exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadingFileName = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _subirVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
          _uploadingFileName = result.files.single.name;
        });

        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        // Subir video con seguimiento de progreso
        final urlArchivo = await _storageService.subirArchivoConProgreso(
          bytes: bytes,
          nombreArchivo: fileName,
          carpeta: 'materiales/${widget.tema.id}/videos',
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );

        // Crear material en Firestore
        final material = EVMCLSMaterial(
          id: '',
          temaId: widget.tema.id,
          nombre: fileName.replaceAll(RegExp(r'\.(mp4|mov|avi|mkv)$', caseSensitive: false), ''),
          descripcion: '',
          tipo: TipoMaterial.video,
          urlArchivo: urlArchivo,
          fechaSubida: DateTime.now(),
        );

        await _firestoreService.crearMaterial(material);

        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadProgress = 0.0;
            _uploadingFileName = '';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video subido exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadingFileName = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarMaterial(EVMCLSMaterial material) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Material'),
        content: Text('¿Estás seguro de eliminar "${material.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Eliminar archivo de Storage
        await _storageService.eliminarArchivo(material.urlArchivo);
        
        // Eliminar registro de Firestore
        await _firestoreService.eliminarMaterial(material.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _mostrarOpcionesSubida() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red.shade700),
              title: const Text('Subir PDF'),
              subtitle: const Text('Documentos, presentaciones, guías'),
              onTap: () {
                Navigator.pop(context);
                _subirPDF();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.video_library, color: Colors.blue.shade700),
              title: const Text('Subir Video'),
              subtitle: const Text('Clases grabadas, tutoriales'),
              onTap: () {
                Navigator.pop(context);
                _subirVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tema.nombre),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Información del tema
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Curso: ${widget.curso.titulo}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.tema.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.tema.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.tema.descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Botón de acceso a Banco de Preguntas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.purple.shade50,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EVMPreguntasListScreen(tema: widget.tema),
                        ),
                      );
                    },
                    icon: const Icon(Icons.question_answer),
                    label: const Text('Banco de Preguntas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EVMEvaluacionConfigScreen(
                            tema: widget.tema,
                            cursoId: widget.curso.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment),
                    label: const Text('Rendir Evaluación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar durante subida
          if (_isUploading)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subiendo: $_uploadingFileName',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: _uploadProgress),
                            const SizedBox(height: 4),
                            Text(
                              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Lista de materiales
          Expanded(
            child: StreamBuilder<List<EVMCLSMaterial>>(
              stream: _firestoreService.obtenerMaterialesTema(widget.tema.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final materiales = snapshot.data ?? [];

                if (materiales.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay materiales aún',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sube PDFs o videos para este tema',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: materiales.length,
                  itemBuilder: (context, index) {
                    final material = materiales[index];
                    final isPDF = material.tipo == TipoMaterial.pdf;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPDF ? Colors.red.shade100 : Colors.blue.shade100,
                          child: Icon(
                            isPDF ? Icons.picture_as_pdf : Icons.play_circle_outline,
                            color: isPDF ? Colors.red.shade700 : Colors.blue.shade700,
                          ),
                        ),
                        title: Text(
                          material.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Subido: ${material.fechaSubida.day}/${material.fechaSubida.month}/${material.fechaSubida.year}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'eliminar') {
                              _eliminarMaterial(material);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // TODO: Abrir visor de PDF o reproductor de video
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Abrir ${isPDF ? 'PDF' : 'video'}: ${material.nombre}'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isUploading
          ? null
          : FloatingActionButton.extended(
              onPressed: _mostrarOpcionesSubida,
              backgroundColor: Colors.green.shade700,
              icon: const Icon(Icons.upload_file),
              label: const Text('Subir Material'),
            ),
    );
  }
}

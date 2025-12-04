import 'package:flutter/material.dart';
import '../models/evmcls_curso.dart';
import '../models/evmcls_tema.dart';
import '../services/evm_firestore_service.dart';
import 'evm_tema_form_screen.dart';
import 'evm_tema_detalle_screen.dart';

class EVMCursoDetalleScreen extends StatefulWidget {
  final EVMCLSCurso curso;

  const EVMCursoDetalleScreen({super.key, required this.curso});

  @override
  State<EVMCursoDetalleScreen> createState() => _EVMCursoDetalleScreenState();
}

class _EVMCursoDetalleScreenState extends State<EVMCursoDetalleScreen> {
  final EVMFirestoreService _firestoreService = EVMFirestoreService();

  void _crearNuevoTema() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EVMTemaFormScreen(cursoId: widget.curso.id),
      ),
    );
  }

  void _verDetalleTema(EVMCLSTema tema) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EVMTemaDetalleScreen(tema: tema, curso: widget.curso),
      ),
    );
  }

  Future<void> _eliminarTema(EVMCLSTema tema) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tema'),
        content: Text('¿Estás seguro de eliminar "${tema.nombre}"?\n\nSe eliminarán todos los materiales y preguntas asociados.'),
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
        await _firestoreService.eliminarTema(tema.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tema eliminado exitosamente'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.curso.titulo),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Información del curso
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.curso.descripcion,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(widget.curso.categoria),
                  backgroundColor: Colors.blue.shade200,
                ),
              ],
            ),
          ),
          
          // Lista de temas
          Expanded(
            child: StreamBuilder<List<EVMCLSTema>>(
              stream: _firestoreService.obtenerTemasCurso(widget.curso.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final temas = snapshot.data ?? [];

                if (temas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay temas en este curso',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea tu primer tema para comenzar',
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
                  itemCount: temas.length,
                  itemBuilder: (context, index) {
                    final tema = temas[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade700,
                          child: Text(
                            '${tema.orden}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          tema.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          tema.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'editar',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'editar') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EVMTemaFormScreen(
                                    cursoId: widget.curso.id,
                                    tema: tema,
                                  ),
                                ),
                              );
                            } else if (value == 'eliminar') {
                              _eliminarTema(tema);
                            }
                          },
                        ),
                        onTap: () => _verDetalleTema(tema),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearNuevoTema,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Tema'),
      ),
    );
  }
}

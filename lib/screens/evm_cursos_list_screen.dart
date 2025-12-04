import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/evm_auth_service.dart';
import '../services/evm_firestore_service.dart';
import '../models/evmcls_curso.dart';
import 'evm_curso_form_screen.dart';
import 'evm_curso_detalle_screen.dart';

class EVMCursosListScreen extends StatefulWidget {
  const EVMCursosListScreen({super.key});

  @override
  State<EVMCursosListScreen> createState() => _EVMCursosListScreenState();
}

class _EVMCursosListScreenState extends State<EVMCursosListScreen> {
  final EVMAuthService _authService = EVMAuthService();
  final EVMFirestoreService _firestoreService = EVMFirestoreService();

  void _crearNuevoCurso() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EVMCursoFormScreen(),
      ),
    );
  }

  void _verDetalleCurso(EVMCLSCurso curso) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EVMCursoDetalleScreen(curso: curso),
      ),
    );
  }

  Future<void> _eliminarCurso(EVMCLSCurso curso) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Curso'),
        content: Text('¿Estás seguro de eliminar "${curso.titulo}"?\n\nSe eliminarán todos los temas, materiales y preguntas asociados.'),
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
        await _firestoreService.eliminarCurso(curso.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Curso eliminado exitosamente'),
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
    final String userId = _authService.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<List<EVMCLSCurso>>(
        stream: _firestoreService.obtenerCursosUsuario(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cursos = snapshot.data ?? [];

          if (cursos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes cursos aún',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primer curso para comenzar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _crearNuevoCurso,
                    icon: Icon(Icons.add),
                    label: Text('Crear Curso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              final curso = cursos[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    radius: 30,
                    child: Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    curso.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        curso.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          curso.categoria,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue.shade100,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
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
                            builder: (context) => EVMCursoFormScreen(curso: curso),
                          ),
                        );
                      } else if (value == 'eliminar') {
                        _eliminarCurso(curso);
                      }
                    },
                  ),
                  onTap: () => _verDetalleCurso(curso),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearNuevoCurso,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Nuevo Curso'),
      ),
    );
  }
}

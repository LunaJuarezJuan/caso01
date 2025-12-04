import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/evm_auth_service.dart';
import '../services/evm_firestore_service.dart';
import '../models/evmcls_curso.dart';

class EVMCursoFormScreen extends StatefulWidget {
  final EVMCLSCurso? curso; // Si es null, es un nuevo curso

  const EVMCursoFormScreen({super.key, this.curso});

  @override
  State<EVMCursoFormScreen> createState() => _EVMCursoFormScreenState();
}

class _EVMCursoFormScreenState extends State<EVMCursoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _categoriaController = TextEditingController();
  
  final EVMAuthService _authService = EVMAuthService();
  final EVMFirestoreService _firestoreService = EVMFirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.curso != null) {
      _tituloController.text = widget.curso!.titulo;
      _descripcionController.text = widget.curso!.descripcion;
      _categoriaController.text = widget.curso!.categoria;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _guardarCurso() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String userId = _authService.currentUser!.uid;

      if (widget.curso == null) {
        // Crear nuevo curso
        final nuevoCurso = EVMCLSCurso(
          id: '',
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          categoria: _categoriaController.text.trim(),
          usuarioId: userId,
          fechaCreacion: DateTime.now(),
        );

        await _firestoreService.crearCurso(nuevoCurso);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Curso creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Actualizar curso existente
        await _firestoreService.actualizarCurso(widget.curso!.id, {
          'titulo': _tituloController.text.trim(),
          'descripcion': _descripcionController.text.trim(),
          'categoria': _categoriaController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Curso actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.curso == null ? 'Nuevo Curso' : 'Editar Curso'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título del Curso',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descripcionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _categoriaController,
              decoration: InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Ej: Matemáticas, Programación, etc.',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _guardarCurso,
                icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.save),
                label: _isLoading
                    ? const Text('Guardando...')
                    : Text(widget.curso == null ? 'Crear Curso' : 'Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

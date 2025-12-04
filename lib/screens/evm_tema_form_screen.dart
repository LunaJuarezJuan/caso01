import 'package:flutter/material.dart';
import '../models/evmcls_tema.dart';
import '../services/evm_firestore_service.dart';

class EVMTemaFormScreen extends StatefulWidget {
  final String cursoId;
  final EVMCLSTema? tema;

  const EVMTemaFormScreen({super.key, required this.cursoId, this.tema});

  @override
  State<EVMTemaFormScreen> createState() => _EVMTemaFormScreenState();
}

class _EVMTemaFormScreenState extends State<EVMTemaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ordenController = TextEditingController();
  
  final EVMFirestoreService _firestoreService = EVMFirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.tema != null) {
      _nombreController.text = widget.tema!.nombre;
      _descripcionController.text = widget.tema!.descripcion;
      _ordenController.text = widget.tema!.orden.toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ordenController.dispose();
    super.dispose();
  }

  Future<void> _guardarTema() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.tema == null) {
        final nuevoTema = EVMCLSTema(
          id: '',
          cursoId: widget.cursoId,
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          orden: int.parse(_ordenController.text.trim()),
          fechaCreacion: DateTime.now(),
        );

        await _firestoreService.crearTema(nuevoTema);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tema creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await _firestoreService.actualizarTema(widget.tema!.id, {
          'nombre': _nombreController.text.trim(),
          'descripcion': _descripcionController.text.trim(),
          'orden': int.parse(_ordenController.text.trim()),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tema actualizado exitosamente'),
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
        title: Text(widget.tema == null ? 'Nuevo Tema' : 'Editar Tema'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Tema',
                prefixIcon: Icon(Icons.topic),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
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
              controller: _ordenController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Orden',
                prefixIcon: Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Número de orden del tema',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa el orden';
                }
                if (int.tryParse(value) == null) {
                  return 'Debe ser un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _guardarTema,
                icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.save),
                label: _isLoading
                    ? const Text('Guardando...')
                    : Text(widget.tema == null ? 'Crear Tema' : 'Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
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

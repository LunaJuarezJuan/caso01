import 'package:flutter/material.dart';
import '../models/evmcls_tema.dart';
import '../models/evmcls_pregunta.dart';
import '../services/evm_firestore_service.dart';

class EVMPreguntaFormScreen extends StatefulWidget {
  final EVMCLSTema tema;
  final EVMCLSPregunta? pregunta;

  const EVMPreguntaFormScreen({
    super.key,
    required this.tema,
    this.pregunta,
  });

  @override
  State<EVMPreguntaFormScreen> createState() => _EVMPreguntaFormScreenState();
}

class _EVMPreguntaFormScreenState extends State<EVMPreguntaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EVMFirestoreService _firestoreService = EVMFirestoreService();
  
  late TextEditingController _enunciadoController;
  late TipoPregunta _tipoPregunta;
  late List<TextEditingController> _opcionesControllers;
  late int _respuestaCorrectaIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.pregunta != null) {
      // Modo edición
      _enunciadoController = TextEditingController(text: widget.pregunta!.enunciado);
      _tipoPregunta = widget.pregunta!.tipo;
      _respuestaCorrectaIndex = int.tryParse(widget.pregunta!.respuestaCorrecta) ?? 0;
      
      if (_tipoPregunta == TipoPregunta.seleccionMultiple) {
        _opcionesControllers = widget.pregunta!.opciones
            .map((opcion) => TextEditingController(text: opcion))
            .toList();
      } else {
        _opcionesControllers = [];
      }
    } else {
      // Modo creación
      _enunciadoController = TextEditingController();
      _tipoPregunta = TipoPregunta.seleccionMultiple;
      _opcionesControllers = List.generate(4, (_) => TextEditingController());
      _respuestaCorrectaIndex = 0;
    }
  }

  @override
  void dispose() {
    _enunciadoController.dispose();
    for (var controller in _opcionesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _agregarOpcion() {
    setState(() {
      _opcionesControllers.add(TextEditingController());
    });
  }

  void _eliminarOpcion(int index) {
    if (_opcionesControllers.length > 2) {
      setState(() {
        _opcionesControllers[index].dispose();
        _opcionesControllers.removeAt(index);
        if (_respuestaCorrectaIndex >= _opcionesControllers.length) {
          _respuestaCorrectaIndex = _opcionesControllers.length - 1;
        }
      });
    }
  }

  Future<void> _guardarPregunta() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar que haya al menos una respuesta correcta
    if (_tipoPregunta == TipoPregunta.seleccionMultiple) {
      if (_opcionesControllers.any((c) => c.text.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las opciones deben tener texto'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final pregunta = EVMCLSPregunta(
        id: widget.pregunta?.id ?? '',
        temaId: widget.tema.id,
        enunciado: _enunciadoController.text.trim(),
        tipo: _tipoPregunta,
        opciones: _tipoPregunta == TipoPregunta.seleccionMultiple
            ? _opcionesControllers.map((c) => c.text.trim()).toList()
            : ['Verdadero', 'Falso'],
        respuestaCorrecta: _respuestaCorrectaIndex.toString(),
        fechaCreacion: widget.pregunta?.fechaCreacion ?? DateTime.now(),
      );

      if (widget.pregunta == null) {
        // Crear nueva
        await _firestoreService.crearPregunta(pregunta);
      } else {
        // Actualizar existente
        await _firestoreService.actualizarPregunta(
          widget.pregunta!.id,
          pregunta.toMap(),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.pregunta == null
                  ? 'Pregunta creada exitosamente'
                  : 'Pregunta actualizada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
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
        title: Text(widget.pregunta == null ? 'Nueva Pregunta' : 'Editar Pregunta'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Información del tema
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.topic, color: Colors.purple.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tema: ${widget.tema.nombre}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tipo de pregunta
            const Text(
              'Tipo de Pregunta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TipoPregunta>(
              segments: const [
                ButtonSegment(
                  value: TipoPregunta.seleccionMultiple,
                  label: Text('Selección Múltiple'),
                  icon: Icon(Icons.radio_button_checked),
                ),
                ButtonSegment(
                  value: TipoPregunta.verdaderoFalso,
                  label: Text('Verdadero/Falso'),
                  icon: Icon(Icons.check_circle),
                ),
              ],
              selected: {_tipoPregunta},
              onSelectionChanged: (Set<TipoPregunta> newSelection) {
                setState(() {
                  _tipoPregunta = newSelection.first;
                  if (_tipoPregunta == TipoPregunta.verdaderoFalso) {
                    // Limpiar opciones y usar V/F
                    for (var controller in _opcionesControllers) {
                      controller.dispose();
                    }
                    _opcionesControllers = [];
                    _respuestaCorrectaIndex = 0;
                  } else if (_opcionesControllers.isEmpty) {
                    // Crear opciones por defecto
                    _opcionesControllers = List.generate(4, (_) => TextEditingController());
                    _respuestaCorrectaIndex = 0;
                  }
                });
              },
            ),
            const SizedBox(height: 20),

            // Enunciado
            const Text(
              'Enunciado de la Pregunta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _enunciadoController,
              decoration: InputDecoration(
                hintText: '¿Cuál es la capital de Perú?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa el enunciado';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Opciones según tipo
            if (_tipoPregunta == TipoPregunta.seleccionMultiple) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Opciones de Respuesta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _agregarOpcion,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar opción'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._opcionesControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: _respuestaCorrectaIndex,
                        onChanged: (value) {
                          setState(() {
                            _respuestaCorrectaIndex = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Opción ${index + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: _opcionesControllers.length > 2
                                ? IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _eliminarOpcion(index),
                                  )
                                : null,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa texto';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else ...[
              const Text(
                'Respuesta Correcta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RadioListTile<int>(
                title: const Text('Verdadero'),
                value: 0,
                groupValue: _respuestaCorrectaIndex,
                onChanged: (value) {
                  setState(() {
                    _respuestaCorrectaIndex = value!;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('Falso'),
                value: 1,
                groupValue: _respuestaCorrectaIndex,
                onChanged: (value) {
                  setState(() {
                    _respuestaCorrectaIndex = value!;
                  });
                },
              ),
            ],
            
            const SizedBox(height: 30),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _guardarPregunta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.pregunta == null ? 'Crear Pregunta' : 'Guardar Cambios'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

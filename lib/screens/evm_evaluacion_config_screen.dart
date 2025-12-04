import 'package:flutter/material.dart';
import '../models/evmcls_tema.dart';
import '../models/evmcls_pregunta.dart';
import '../services/evm_firestore_service.dart';
import 'evm_evaluacion_render_screen.dart';

class EVMEvaluacionConfigScreen extends StatefulWidget {
  final EVMCLSTema tema;
  final String cursoId;

  const EVMEvaluacionConfigScreen({
    super.key,
    required this.tema,
    required this.cursoId,
  });

  @override
  State<EVMEvaluacionConfigScreen> createState() => _EVMEvaluacionConfigScreenState();
}

class _EVMEvaluacionConfigScreenState extends State<EVMEvaluacionConfigScreen> {
  final EVMFirestoreService _firestoreService = EVMFirestoreService();
  
  int _numeroPreguntasSeleccionadas = 10;
  bool _usarCronometro = false;
  int _minutosLimite = 15;
  List<EVMCLSPregunta> _preguntasDisponibles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  Future<void> _cargarPreguntas() async {
    try {
      final preguntas = await _firestoreService
          .obtenerPreguntasTema(widget.tema.id)
          .first;
      
      setState(() {
        _preguntasDisponibles = preguntas;
        _isLoading = false;
        
        // Ajustar número de preguntas si hay menos disponibles
        if (_numeroPreguntasSeleccionadas > preguntas.length) {
          _numeroPreguntasSeleccionadas = preguntas.length;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar preguntas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _iniciarEvaluacion() {
    if (_preguntasDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay preguntas disponibles para este tema'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Seleccionar preguntas aleatorias
    final preguntasAleatorias = List<EVMCLSPregunta>.from(_preguntasDisponibles)
      ..shuffle();
    final preguntasEvaluacion = preguntasAleatorias.take(_numeroPreguntasSeleccionadas).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EVMEvaluacionRenderScreen(
          tema: widget.tema,
          preguntas: preguntasEvaluacion,
          usarCronometro: _usarCronometro,
          minutosLimite: _minutosLimite,
          cursoId: widget.cursoId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Evaluación'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del tema
                  Card(
                    color: Colors.indigo.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.topic, color: Colors.indigo.shade700, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.tema.nombre,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_preguntasDisponibles.length} preguntas disponibles',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Número de preguntas
                  const Text(
                    'Número de Preguntas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Preguntas a responder:'),
                              Text(
                                '$_numeroPreguntasSeleccionadas',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                          if (_preguntasDisponibles.isNotEmpty)
                            Slider(
                              value: _numeroPreguntasSeleccionadas.toDouble(),
                              min: 1,
                              max: _preguntasDisponibles.length.toDouble(),
                              divisions: _preguntasDisponibles.length - 1,
                              label: '$_numeroPreguntasSeleccionadas',
                              onChanged: (value) {
                                setState(() {
                                  _numeroPreguntasSeleccionadas = value.toInt();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Cronómetro
                  const Text(
                    'Tiempo Límite',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Usar cronómetro'),
                          subtitle: const Text('Limitar el tiempo de evaluación'),
                          value: _usarCronometro,
                          onChanged: (value) {
                            setState(() {
                              _usarCronometro = value;
                            });
                          },
                        ),
                        if (_usarCronometro) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Tiempo límite:'),
                                    Text(
                                      '$_minutosLimite minutos',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _minutosLimite.toDouble(),
                                  min: 5,
                                  max: 60,
                                  divisions: 11,
                                  label: '$_minutosLimite min',
                                  onChanged: (value) {
                                    setState(() {
                                      _minutosLimite = value.toInt();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resumen
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Resumen de Evaluación',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildResumenItem(
                            Icons.quiz,
                            'Preguntas',
                            '$_numeroPreguntasSeleccionadas de ${_preguntasDisponibles.length}',
                          ),
                          _buildResumenItem(
                            Icons.shuffle,
                            'Orden',
                            'Aleatorio',
                          ),
                          _buildResumenItem(
                            Icons.timer,
                            'Tiempo',
                            _usarCronometro ? '$_minutosLimite minutos' : 'Sin límite',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botón iniciar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _preguntasDisponibles.isEmpty ? null : _iniciarEvaluacion,
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text(
                        'Iniciar Evaluación',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildResumenItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

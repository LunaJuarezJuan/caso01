import 'dart:async';
import 'package:flutter/material.dart';
import '../models/evmcls_curso.dart';
import '../models/evmcls_tema.dart';
import '../models/evmcls_pregunta.dart';
import '../models/evmcls_evaluacion.dart';
import '../services/evm_firestore_service.dart';
import '../services/evm_auth_service.dart';
import 'evm_evaluacion_resultados_screen.dart';

class EVMEvaluacionRenderScreen extends StatefulWidget {
  final EVMCLSTema tema;
  final List<EVMCLSPregunta> preguntas;
  final bool usarCronometro;
  final int minutosLimite;
  final String cursoId;

  const EVMEvaluacionRenderScreen({
    super.key,
    required this.tema,
    required this.preguntas,
    required this.usarCronometro,
    required this.minutosLimite,
    required this.cursoId,
  });

  @override
  State<EVMEvaluacionRenderScreen> createState() => _EVMEvaluacionRenderScreenState();
}

class _EVMEvaluacionRenderScreenState extends State<EVMEvaluacionRenderScreen> {
  final PageController _pageController = PageController();
  final Map<int, int> _respuestasUsuario = {};
  
  int _preguntaActual = 0;
  Timer? _timer;
  int _segundosRestantes = 0;
  bool _evaluacionFinalizada = false;

  @override
  void initState() {
    super.initState();
    if (widget.usarCronometro) {
      _segundosRestantes = widget.minutosLimite * 60;
      _iniciarCronometro();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _iniciarCronometro() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_segundosRestantes > 0) {
          _segundosRestantes--;
        } else {
          _finalizarEvaluacion();
        }
      });
    });
  }

  void _seleccionarRespuesta(int indicePregunta, int indiceRespuesta) {
    setState(() {
      _respuestasUsuario[indicePregunta] = indiceRespuesta;
    });
  }

  void _navegarPregunta(int nuevaPregunta) {
    setState(() {
      _preguntaActual = nuevaPregunta;
    });
    _pageController.animateToPage(
      nuevaPregunta,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finalizarEvaluacion() async {
    if (_evaluacionFinalizada) return;
    
    setState(() => _evaluacionFinalizada = true);
    _timer?.cancel();

    // Calcular puntuación
    int respuestasCorrectas = 0;
    for (int i = 0; i < widget.preguntas.length; i++) {
      final respuestaUsuario = _respuestasUsuario[i];
      if (respuestaUsuario != null) {
        final pregunta = widget.preguntas[i];
        final respuestaCorrectaIndex = int.parse(pregunta.respuestaCorrecta);
        if (respuestaUsuario == respuestaCorrectaIndex) {
          respuestasCorrectas++;
        }
      }
    }

    final puntuacion = (respuestasCorrectas / widget.preguntas.length * 100).round();
    final tiempoTranscurrido = widget.usarCronometro 
        ? (widget.minutosLimite * 60) - _segundosRestantes 
        : 0;

    // Guardar evaluación en Firestore
    try {
      final authService = EVMAuthService();
      final user = authService.currentUser;
      
      if (user != null) {
        final evaluacion = EVMCLSEvaluacion(
          id: '',
          usuarioId: user.uid,
          temaId: widget.tema.id,
          cursoId: widget.cursoId,
          puntajeObtenido: respuestasCorrectas,
          puntajeTotal: widget.preguntas.length,
          porcentaje: puntuacion.toDouble(),
          duracionSegundos: tiempoTranscurrido,
          respuestasUsuario: _respuestasUsuario.map((k, v) => MapEntry(k.toString(), v.toString())),
          fechaRealizacion: DateTime.now(),
        );

        final firestoreService = EVMFirestoreService();
        await firestoreService.guardarEvaluacion(evaluacion);
      }
    } catch (e) {
      debugPrint('Error al guardar evaluación: $e');
    }

    // Navegar a resultados
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EVMEvaluacionResultadosScreen(
            tema: widget.tema,
            preguntas: widget.preguntas,
            respuestasUsuario: _respuestasUsuario,
            puntuacion: puntuacion,
            respuestasCorrectas: respuestasCorrectas,
          ),
        ),
      );
    }
  }

  String _formatearTiempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final confirmar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Salir de la evaluación?'),
            content: const Text('Si sales ahora, perderás todo tu progreso.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Salir'),
              ),
            ],
          ),
        );
        return confirmar ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pregunta ${_preguntaActual + 1}/${widget.preguntas.length}'),
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          actions: [
            if (widget.usarCronometro)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _segundosRestantes < 60 ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: _segundosRestantes < 60 ? Colors.white : Colors.indigo.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatearTiempo(_segundosRestantes),
                        style: TextStyle(
                          color: _segundosRestantes < 60 ? Colors.white : Colors.indigo.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Barra de progreso
            LinearProgressIndicator(
              value: (_preguntaActual + 1) / widget.preguntas.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade700),
            ),

            // Navegador de preguntas
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.preguntas.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  final respondida = _respuestasUsuario.containsKey(index);
                  final esActual = index == _preguntaActual;

                  return GestureDetector(
                    onTap: () => _navegarPregunta(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 44,
                      decoration: BoxDecoration(
                        color: esActual
                            ? Colors.indigo.shade700
                            : respondida
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: esActual ? Colors.indigo.shade900 : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: esActual ? Colors.white : Colors.black87,
                            fontWeight: esActual ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Contenido de preguntas
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.preguntas.length,
                onPageChanged: (index) {
                  setState(() => _preguntaActual = index);
                },
                itemBuilder: (context, index) {
                  final pregunta = widget.preguntas[index];
                  final respuestaSeleccionada = _respuestasUsuario[index];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enunciado
                        Card(
                          color: Colors.indigo.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      pregunta.tipo == TipoPregunta.seleccionMultiple
                                          ? Icons.radio_button_checked
                                          : Icons.check_circle,
                                      color: Colors.indigo.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        pregunta.tipo == TipoPregunta.seleccionMultiple
                                            ? 'Selección Múltiple'
                                            : 'Verdadero/Falso',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  pregunta.enunciado,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Opciones
                        ...pregunta.opciones.asMap().entries.map((entry) {
                          final indiceOpcion = entry.key;
                          final textoOpcion = entry.value;
                          final esSeleccionada = respuestaSeleccionada == indiceOpcion;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _seleccionarRespuesta(index, indiceOpcion),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: esSeleccionada
                                      ? Colors.indigo.shade100
                                      : Colors.white,
                                  border: Border.all(
                                    color: esSeleccionada
                                        ? Colors.indigo.shade700
                                        : Colors.grey.shade300,
                                    width: esSeleccionada ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: esSeleccionada
                                            ? Colors.indigo.shade700
                                            : Colors.white,
                                        border: Border.all(
                                          color: esSeleccionada
                                              ? Colors.indigo.shade700
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 + indiceOpcion),
                                          style: TextStyle(
                                            color: esSeleccionada
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        textoOpcion,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: esSeleccionada
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Botones de navegación
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_preguntaActual > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navegarPregunta(_preguntaActual - 1),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Anterior'),
                      ),
                    ),
                  if (_preguntaActual > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _preguntaActual < widget.preguntas.length - 1
                          ? () => _navegarPregunta(_preguntaActual + 1)
                          : _finalizarEvaluacion,
                      icon: Icon(
                        _preguntaActual < widget.preguntas.length - 1
                            ? Icons.arrow_forward
                            : Icons.check_circle,
                      ),
                      label: Text(
                        _preguntaActual < widget.preguntas.length - 1
                            ? 'Siguiente'
                            : 'Finalizar',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _preguntaActual < widget.preguntas.length - 1
                            ? Colors.indigo.shade700
                            : Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

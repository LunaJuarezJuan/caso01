import 'package:flutter/material.dart';
import '../models/evmcls_tema.dart';
import '../models/evmcls_pregunta.dart';

class EVMEvaluacionResultadosScreen extends StatelessWidget {
  final EVMCLSTema tema;
  final List<EVMCLSPregunta> preguntas;
  final Map<int, int> respuestasUsuario;
  final int puntuacion;
  final int respuestasCorrectas;

  const EVMEvaluacionResultadosScreen({
    super.key,
    required this.tema,
    required this.preguntas,
    required this.respuestasUsuario,
    required this.puntuacion,
    required this.respuestasCorrectas,
  });

  Color _getColorPuntuacion() {
    if (puntuacion >= 90) return Colors.green;
    if (puntuacion >= 70) return Colors.blue;
    if (puntuacion >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getMensajePuntuacion() {
    if (puntuacion >= 90) return '¡Excelente trabajo! 🎉';
    if (puntuacion >= 70) return '¡Buen trabajo! 👍';
    if (puntuacion >= 50) return 'Puedes mejorar 💪';
    return 'Sigue practicando 📚';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: _getColorPuntuacion(),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera con puntuación
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getColorPuntuacion(),
                    _getColorPuntuacion().withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getMensajePuntuacion(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$puntuacion%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getColorPuntuacion(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$respuestasCorrectas de ${preguntas.length} correctas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Estadísticas
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Correctas',
                      respuestasCorrectas.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Incorrectas',
                      (preguntas.length - respuestasCorrectas).toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      preguntas.length.toString(),
                      Icons.quiz,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Revisión detallada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revisión Detallada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...preguntas.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pregunta = entry.value;
                    final respuestaUsuario = respuestasUsuario[index];
                    final respuestaCorrectaIndex = int.parse(pregunta.respuestaCorrecta);
                    final esCorrecta = respuestaUsuario == respuestaCorrectaIndex;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: esCorrecta
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            esCorrecta ? Icons.check : Icons.close,
                            color: esCorrecta ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          'Pregunta ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          pregunta.enunciado,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Enunciado completo
                                Text(
                                  pregunta.enunciado,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Opciones
                                ...pregunta.opciones.asMap().entries.map((opcionEntry) {
                                  final indiceOpcion = opcionEntry.key;
                                  final textoOpcion = opcionEntry.value;
                                  final esRespuestaCorrecta = indiceOpcion == respuestaCorrectaIndex;
                                  final esRespuestaUsuario = respuestaUsuario == indiceOpcion;

                                  Color? colorFondo;
                                  Color? colorBorde;
                                  IconData? icono;

                                  if (esRespuestaCorrecta) {
                                    colorFondo = Colors.green.shade50;
                                    colorBorde = Colors.green.shade700;
                                    icono = Icons.check_circle;
                                  } else if (esRespuestaUsuario && !esCorrecta) {
                                    colorFondo = Colors.red.shade50;
                                    colorBorde = Colors.red.shade700;
                                    icono = Icons.cancel;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorFondo,
                                      border: Border.all(
                                        color: colorBorde ?? Colors.grey.shade300,
                                        width: colorBorde != null ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${String.fromCharCode(65 + indiceOpcion)}. ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(child: Text(textoOpcion)),
                                        if (icono != null)
                                          Icon(
                                            icono,
                                            color: esRespuestaCorrecta
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                // Información adicional
                                const SizedBox(height: 12),
                                if (!esCorrecta)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            respuestaUsuario == null
                                                ? 'No respondiste esta pregunta'
                                                : 'Tu respuesta fue incorrecta',
                                            style: TextStyle(color: Colors.blue.shade900),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Volver al Inicio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Nueva Evaluación'),
                      style: OutlinedButton.styleFrom(
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

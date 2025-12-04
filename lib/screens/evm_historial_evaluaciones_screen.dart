import 'package:flutter/material.dart';
import '../models/evmcls_evaluacion.dart';
import '../services/evm_firestore_service.dart';
import '../services/evm_auth_service.dart';
import 'package:intl/intl.dart';

class EVMHistorialEvaluacionesScreen extends StatelessWidget {
  const EVMHistorialEvaluacionesScreen({super.key});

  Color _getColorPorPuntuacion(int puntuacion) {
    if (puntuacion >= 90) return Colors.green;
    if (puntuacion >= 70) return Colors.blue;
    if (puntuacion >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getIconoPorPuntuacion(int puntuacion) {
    if (puntuacion >= 90) return '🏆';
    if (puntuacion >= 70) return '⭐';
    if (puntuacion >= 50) return '👍';
    return '📚';
  }

  @override
  Widget build(BuildContext context) {
    final authService = EVMAuthService();
    final user = authService.currentUser;
    final firestoreService = EVMFirestoreService();

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Historial de Evaluaciones'),
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Debes iniciar sesión'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Evaluaciones'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<EVMCLSEvaluacion>>(
        stream: firestoreService.obtenerHistorialEvaluaciones(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final evaluaciones = snapshot.data ?? [];

          if (evaluaciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No has rendido evaluaciones',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Empieza a evaluarte para ver tu historial',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calcular estadísticas
          final promedioGeneral = evaluaciones.isNotEmpty
              ? evaluaciones.map((e) => e.porcentaje).reduce((a, b) => a + b) / evaluaciones.length
              : 0.0;
          final mejorPuntuacion = evaluaciones.isNotEmpty
              ? evaluaciones.map((e) => e.porcentaje).reduce((a, b) => a > b ? a : b).toInt()
              : 0;

          return Column(
            children: [
              // Estadísticas generales
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade700,
                      Colors.indigo.shade500,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Estadísticas Generales',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          'Total',
                          evaluaciones.length.toString(),
                          Icons.assignment,
                        ),
                        _buildStatItem(
                          'Promedio',
                          '${promedioGeneral.toStringAsFixed(1)}%',
                          Icons.trending_up,
                        ),
                        _buildStatItem(
                          'Mejor',
                          '$mejorPuntuacion%',
                          Icons.emoji_events,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de evaluaciones
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: evaluaciones.length,
                  itemBuilder: (context, index) {
                    final evaluacion = evaluaciones[index];
                    final color = _getColorPorPuntuacion(evaluacion.porcentaje.toInt());
                    final icono = _getIconoPorPuntuacion(evaluacion.porcentaje.toInt());

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          _mostrarDetalleEvaluacion(context, evaluacion);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Puntuación
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: color,
                                    width: 3,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      icono,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      '${evaluacion.porcentaje.toInt()}%',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Información
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Evaluación ${evaluaciones.length - index}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${evaluacion.puntajeObtenido} de ${evaluacion.puntajeTotal} correctas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(evaluacion.fechaRealizacion),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Indicador
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalleEvaluacion(BuildContext context, EVMCLSEvaluacion evaluacion) {
    final color = _getColorPorPuntuacion(evaluacion.porcentaje.toInt());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalle de Evaluación'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      '${evaluacion.porcentaje.toInt()}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Fecha:', DateFormat('dd/MM/yyyy HH:mm').format(evaluacion.fechaRealizacion)),
              _buildDetailRow('Total preguntas:', evaluacion.puntajeTotal.toString()),
              _buildDetailRow('Correctas:', '${evaluacion.puntajeObtenido} ✓', color: Colors.green),
              _buildDetailRow(
                'Incorrectas:',
                '${evaluacion.puntajeTotal - evaluacion.puntajeObtenido} ✗',
                color: Colors.red,
              ),
              _buildDetailRow('Puntuación:', '${evaluacion.porcentaje.toInt()}%', color: color),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

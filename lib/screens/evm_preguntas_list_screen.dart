import 'package:flutter/material.dart';
import '../models/evmcls_tema.dart';
import '../models/evmcls_pregunta.dart';
import '../services/evm_firestore_service.dart';
import 'evm_pregunta_form_screen.dart';

class EVMPreguntasListScreen extends StatefulWidget {
  final EVMCLSTema tema;

  const EVMPreguntasListScreen({
    super.key,
    required this.tema,
  });

  @override
  State<EVMPreguntasListScreen> createState() => _EVMPreguntasListScreenState();
}

class _EVMPreguntasListScreenState extends State<EVMPreguntasListScreen> {
  final EVMFirestoreService _firestoreService = EVMFirestoreService();

  void _crearPregunta() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EVMPreguntaFormScreen(tema: widget.tema),
      ),
    );
  }

  void _editarPregunta(EVMCLSPregunta pregunta) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EVMPreguntaFormScreen(
          tema: widget.tema,
          pregunta: pregunta,
        ),
      ),
    );
  }

  Future<void> _eliminarPregunta(EVMCLSPregunta pregunta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Pregunta'),
        content: Text('¿Estás seguro de eliminar esta pregunta?\n\n"${pregunta.enunciado}"'),
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
        await _firestoreService.eliminarPregunta(pregunta.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pregunta eliminada exitosamente'),
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
        title: const Text('Banco de Preguntas'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Información del tema
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.purple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema: ${widget.tema.nombre}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestiona las preguntas para evaluaciones',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Lista de preguntas
          Expanded(
            child: StreamBuilder<List<EVMCLSPregunta>>(
              stream: _firestoreService.obtenerPreguntasTema(widget.tema.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final preguntas = snapshot.data ?? [];

                if (preguntas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay preguntas aún',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea preguntas para este tema',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _crearPregunta,
                          icon: const Icon(Icons.add),
                          label: const Text('Crear Pregunta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: preguntas.length,
                  itemBuilder: (context, index) {
                    final pregunta = preguntas[index];
                    final esMultiple = pregunta.tipo == TipoPregunta.seleccionMultiple;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: esMultiple 
                              ? Colors.blue.shade100 
                              : Colors.orange.shade100,
                          child: Icon(
                            esMultiple ? Icons.radio_button_checked : Icons.check_circle,
                            color: esMultiple ? Colors.blue.shade700 : Colors.orange.shade700,
                          ),
                        ),
                        title: Text(
                          pregunta.enunciado,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              esMultiple ? 'Selección Múltiple' : 'Verdadero/Falso',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (esMultiple) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${pregunta.opciones.length} opciones',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') {
                              _editarPregunta(pregunta);
                            } else if (value == 'eliminar') {
                              _eliminarPregunta(pregunta);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'editar',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
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
        onPressed: _crearPregunta,
        backgroundColor: Colors.purple.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Pregunta'),
      ),
    );
  }
}

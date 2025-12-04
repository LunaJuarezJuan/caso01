import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/evm_auth_service.dart';
import '../services/evm_firestore_service.dart';
import '../models/evmcls_curso.dart';
import 'evm_login_screen.dart';
import 'evm_cursos_list_screen.dart';
import 'evm_estadisticas_screen.dart';
import 'evm_historial_evaluaciones_screen.dart';

class EVMHomeScreen extends StatefulWidget {
  const EVMHomeScreen({super.key});

  @override
  State<EVMHomeScreen> createState() => _EVMHomeScreenState();
}

class _EVMHomeScreenState extends State<EVMHomeScreen> {
  final EVMAuthService _authService = EVMAuthService();
  final EVMFirestoreService _firestoreService = EVMFirestoreService();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const EVMCursosListScreen(),
    const EVMHistorialEvaluacionesScreen(),
    const EVMEstadisticasScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const EVMLoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EVM Cursos'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            tooltip: user?.email ?? '',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Perfil'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user?.email ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text(
                        'Email verificado: ${user?.emailVerified == true ? 'Sí' : 'No'}',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue.shade700,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Cursos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}

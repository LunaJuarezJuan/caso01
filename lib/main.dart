import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/evm_login_screen.dart';
import 'screens/evm_home_screen.dart';
import 'screens/evm_verificacion_email_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EVMCursosApp());
}

class EVMCursosApp extends StatelessWidget {
  const EVMCursosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVM Cursos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          
          // Verificar si el email está verificado
          if (user.emailVerified) {
            return const EVMHomeScreen();
          } else {
            return const EVMVerificacionEmailScreen();
          }
        }

        return const EVMLoginScreen();
      },
    );
  }
}

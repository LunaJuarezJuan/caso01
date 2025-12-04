import 'package:firebase_auth/firebase_auth.dart';

class EVMAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream del usuario actual
  Stream<User?> get userStream => _auth.authStateChanges();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Registrar nuevo usuario
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Enviar correo de verificación
      await result.user?.sendEmailVerification();
      
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Iniciar sesión
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verificar si el email está verificado
      if (result.user != null && !result.user!.emailVerified) {
        throw Exception('Por favor verifica tu correo electrónico antes de iniciar sesión');
      }
      
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Iniciar sesión con Google (solo web)
  Future<User?> signInWithGoogle() async {
    try {
      // Crear el proveedor de Google
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      // Agregar scopes opcionales
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      // Iniciar sesión con popup (web) o nativo (móvil)
      UserCredential result = await _auth.signInWithPopup(googleProvider);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reenviar email de verificación
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Verificar si el email está verificado
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Recargar usuario para actualizar estado de verificación
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Manejo de excepciones
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Por seguridad, el acceso ha sido bloqueado temporalmente. Intenta de nuevo en 15-30 minutos o usa otro método de autenticación.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
      case 'operation-not-allowed':
        return 'Este método de inicio de sesión no está habilitado.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}

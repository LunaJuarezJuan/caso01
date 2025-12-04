# 🔐 Configuración de Google Sign-In

## ✅ IMPLEMENTACIÓN COMPLETADA

Se ha implementado Google Sign-In usando **Firebase Auth nativo** (sin el paquete google_sign_in) para mejor compatibilidad.

## 🎯 Cómo Funciona

El método `signInWithPopup()` de Firebase Auth:
1. Abre un popup de Google Sign-In
2. Usuario selecciona su cuenta Google
3. Firebase autentica automáticamente
4. Usuario redirigido a Home Screen

**Código implementado:**
```dart
// lib/services/evm_auth_service.dart
Future<User?> signInWithGoogle() async {
  GoogleAuthProvider googleProvider = GoogleAuthProvider();
  UserCredential result = await _auth.signInWithPopup(googleProvider);
  return result.user;
}
```

## 📋 Paso 1: Habilitar Google Sign-In en Firebase (REQUERIDO)

### En Firebase Console:

1. Ve a [Firebase Console - Authentication](https://console.firebase.google.com/project/evmu3-b93d0/authentication/providers)

2. Click en **Sign-in method**

3. Click en **Google** en la lista de proveedores

4. **Activa** el toggle "Enable"

5. Configura:
   - ✅ **Project support email**: Selecciona tu email
   - ✅ **Project public-facing name**: "EVM Cursos App"

6. Click **Save**

## 🌐 Paso 2: Configurar Dominios Autorizados (Ya configurado)

## 🌐 Paso 2: Configurar Dominios Autorizados (Ya configurado)

Firebase ya tiene configurados los dominios necesarios:
- ✅ `localhost`
- ✅ Dominios de Firebase Hosting

**No necesitas hacer nada aquí para desarrollo local.**

## 🚀 Paso 3: ¡Listo para Usar!

La app ya está funcionando con:
- ✅ Botón "Continuar con Google" en pantalla de login
- ✅ Firebase Auth nativo (sin dependencias externas problemáticas)
- ✅ Funciona en Web (Chrome) inmediatamente
- ✅ No require configuración OAuth adicional para desarrollo

### Cómo Probar:

1. **Asegúrate de habilitar Google en Firebase Console** (Paso 1 arriba)

2. Ejecuta la app:
   ```powershell
   flutter run -d chrome
   ```

3. En la pantalla de login, haz clic en **"Continuar con Google"**

4. Se abrirá un popup de Google Sign-In

5. Selecciona tu cuenta Google

6. ¡Listo! Estarás en la pantalla de inicio

## 🔧 Solución de Problemas

### Error: "popup_blocked_by_browser"
**Solución:** Permite popups en Chrome para `localhost`
- Chrome Settings → Privacy → Site Settings → Popups → Permitir para localhost

### Error: "unauthorized-domain"
**Solución:** Espera 5-10 minutos después de habilitar Google Sign-In
- Firebase necesita propagar la configuración

### Error: "operation-not-allowed"
**Solución:** Google Sign-In no está habilitado en Firebase
- Ve al Paso 1 y habilita el proveedor de Google

### Error: "popup-closed-by-user"
**Información:** El usuario cerró el popup antes de completar el sign-in
- Esto es normal, el usuario puede intentar nuevamente

## 📱 Para Android (Futuro)

Cuando quieras probar en Android:

## 📱 Para Android (Futuro)

Cuando quieras probar en Android:

1. Obtén el SHA-1:
   ```powershell
   cd android
   .\gradlew signingReport
   ```

2. En Firebase Console → Project Settings → General → Tu app Android
3. Agrega el SHA-1 fingerprint

## ✨ Ventajas de Esta Implementación

| Aspecto | Detalle |
|---------|---------|
| **Simplicidad** | Usa Firebase Auth nativo, sin paquetes adicionales |
| **Compatibilidad** | No hay problemas de versión de API |
| **Web** | Funciona inmediatamente en Chrome |
| **Mantenimiento** | Menos dependencias = menos problemas |
| **Código** | Más limpio y fácil de entender |

## 📊 Estado Actual

| Componente | Estado | Notas |
|------------|--------|-------|
| Firebase Auth | ✅ Configurado | |
| Email/Password | ✅ Funcionando | |
| **Google Sign-In** | ⚠️ **Implementado, pendiente habilitar en Console** | Paso 1 requerido |
| Botón UI | ✅ Agregado | Con logo de Google |
| Web (Chrome) | ✅ Listo | |
| Android | ⏳ Pendiente SHA-1 | Futuro |

## 🎓 Código de Referencia

### Servicio de Autenticación
```dart
// lib/services/evm_auth_service.dart
Future<User?> signInWithGoogle() async {
  GoogleAuthProvider googleProvider = GoogleAuthProvider();
  googleProvider.addScope('email');
  googleProvider.addScope('profile');
  UserCredential result = await _auth.signInWithPopup(googleProvider);
  return result.user;
}
```

### UI del Botón
```dart
// lib/screens/evm_login_screen.dart
ElevatedButton(
  onPressed: _loginWithGoogle,
  child: Row(
    children: [
      Image.network('https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg'),
      Text('Continuar con Google'),
    ],
  ),
)
```

---

**Actualizado**: Diciembre 4, 2025  
**Método**: Firebase Auth nativo con `signInWithPopup()`  
**Sin dependencias**: No usa `google_sign_in` package  
**Estado**: ✅ Implementado, ⏳ Pendiente habilitar en Firebase Console

## 🚀 PRÓXIMO PASO

**Ve a Firebase Console AHORA y habilita Google Sign-In:**

👉 [Click aquí para ir a Authentication](https://console.firebase.google.com/project/evmu3-b93d0/authentication/providers)

1. Click en "Google"
2. Toggle "Enable" a ON
3. Ingresa tu email
4. Save

¡Luego prueba el botón "Continuar con Google" en tu app!


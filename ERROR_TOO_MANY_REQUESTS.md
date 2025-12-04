# 🚨 Error: Demasiados Intentos de Autenticación

## ❌ Problema Actual

Firebase ha bloqueado temporalmente las solicitudes de autenticación desde tu dispositivo debido a:

```
[firebase_auth/too-many-requests] 
We have blocked all requests from this device due to unusual activity. 
Try again later.
```

## ⏱️ SOLUCIONES

### Solución 1: Esperar (RECOMENDADO)
- ⏰ Espera **15-30 minutos**
- Firebase levantará el bloqueo automáticamente
- Es la solución más segura

### Solución 2: Cambiar de Red/Navegador
Prueba con:
- ✅ Navegador en modo incógnito
- ✅ Otro navegador (Edge, Firefox)
- ✅ Otra red WiFi
- ✅ Conexión de datos móviles (si tienes laptop con SIM)

### Solución 3: Limpiar Caché
```powershell
# Limpiar build de Flutter
cd d:\proyectos\evm_cursos_app
flutter clean
flutter pub get
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Solución 4: Usar Otro Dispositivo
- Ejecuta la app en Windows: `flutter run -d windows`
- Usa otro computador temporalmente

## 🔐 ¿Por Qué Sucede Esto?

Firebase implementa **protección contra ataques de fuerza bruta**:

1. Detecta múltiples intentos fallidos de login
2. Detecta muchos registros desde la misma IP
3. Actividad inusual en corto tiempo

Durante el desarrollo es común porque:
- ❌ Hacemos muchas pruebas de login/registro
- ❌ Registramos usuarios de prueba constantemente
- ❌ Reiniciamos la app muchas veces

## ✅ Configuración Actual

Tu app ya tiene mejorado el manejo de errores:

```dart
case 'too-many-requests':
  return 'Demasiados intentos fallidos. Por seguridad, el acceso ha sido 
          bloqueado temporalmente. Intenta de nuevo en 15-30 minutos o 
          usa otro método de autenticación.';
```

## 🛡️ Prevención Futura

### Para Desarrollo:
1. **Usa usuarios de prueba fijos** en vez de crear nuevos cada vez
2. **Habilita App Check** en Firebase (protección avanzada)
3. **Configura dominios autorizados** en Firebase Auth

### Habilitar Dominios Autorizados:
1. Ve a [Firebase Console](https://console.firebase.google.com/project/evmu3-b93d0)
2. **Authentication** → **Settings** → **Authorized domains**
3. Agrega:
   - `localhost` ✅
   - Tu dominio de producción

### Configurar App Check (Opcional - Avanzado):
```powershell
# Instalar App Check
flutter pub add firebase_app_check
```

Luego en `main.dart`:
```dart
import 'package:firebase_app_check/firebase_app_check.dart';

await FirebaseAppCheck.instance.activate(
  webRecaptchaSiteKey: 'tu-recaptcha-site-key',
);
```

## 📊 Estado Actual de tu App

| Servicio | Estado |
|----------|--------|
| Firebase Auth | ✅ Configurado |
| Email/Password | ✅ Habilitado |
| Google Sign-In | ❌ Removido temporalmente |
| Firestore | ✅ Configurado |
| Storage | ✅ Configurado |
| Mensaje de Error | ✅ Mejorado |

## 🎯 Próximos Pasos

### AHORA MISMO:
1. ⏰ **Espera 15-30 minutos**
2. 🌐 O cambia de red/navegador
3. 🔄 Vuelve a intentar

### Cuando Funcione de Nuevo:
1. ✅ Crea **1 usuario de prueba** y guarda las credenciales
2. ✅ Usa siempre ese mismo usuario para pruebas
3. ✅ Evita crear/eliminar usuarios constantemente

### Para Habilitar Google Sign-In Después:
Necesitarás:
1. Configurar OAuth 2.0 en Google Cloud Console
2. Agregar Client ID en Firebase
3. Re-agregar el paquete `google_sign_in`

## 🆘 Si el Error Persiste

Si después de 30 minutos sigue el error:

1. **Verifica tu cuenta de Firebase**
   - Puede estar temporalmente suspendida
   - Revisa tu email de Firebase

2. **Prueba en otra plataforma**
   ```powershell
   flutter run -d windows
   ```

3. **Revisa la consola de Firebase**
   - [Monitoring → Usage](https://console.firebase.google.com/project/evmu3-b93d0/usage)
   - Verifica si hay problemas

## 📝 Usuarios de Prueba Sugeridos

Crea estos usuarios y úsalos siempre:

```
Email: test1@evm.com
Password: test123456

Email: test2@evm.com  
Password: test123456

Email: admin@evm.com
Password: admin123456
```

---

**Actualizado**: Diciembre 4, 2025  
**Error Mejorado**: Mensaje más descriptivo implementado ✅  
**Estado**: Esperando que Firebase levante el bloqueo (15-30 min)

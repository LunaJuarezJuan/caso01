# 🚀 Guía Rápida: Probar Google Sign-In

## ✅ Lo que YA está hecho:

1. ✅ Código implementado en `evm_auth_service.dart`
2. ✅ Botón agregado en `evm_login_screen.dart`
3. ✅ App ejecutándose en Chrome
4. ✅ Sin errores de compilación

## ⚠️ Lo que FALTA (1 minuto):

**SOLO necesitas habilitar Google Sign-In en Firebase Console:**

### 📋 Pasos (muy simple):

1. **Abre Firebase Console:**
   ```
   https://console.firebase.google.com/project/evmu3-b93d0/authentication/providers
   ```

2. **Click en "Google"** en la lista de proveedores

3. **Activa el toggle** (de OFF a ON)

4. **Configura:**
   - **Support email:** Selecciona tu email de la lista
   - **Project name:** "EVM Cursos App" (o déjalo como está)

5. **Click "Save"**

¡ESO ES TODO! 🎉

---

## 🧪 Cómo Probar

### La app ya está corriendo:

1. Ve a la ventana de Chrome donde está la app

2. Si no estás en la pantalla de login, cierra sesión

3. En la pantalla de login verás:

   ```
   ┌─────────────────────────────┐
   │  📧 Email/Password          │
   │                             │
   │  [Correo Electrónico]       │
   │  [Contraseña]               │
   │                             │
   │  [Iniciar Sesión]           │
   ├─────────────────────────────┤
   │           O                 │
   ├─────────────────────────────┤
   │  🔍 [G] Continuar con       │
   │         Google              │
   └─────────────────────────────┘
   ```

4. **Click en "Continuar con Google"**

5. Se abrirá un **popup de Google**

6. **Selecciona tu cuenta Google**

7. **¡Listo!** → Serás redirigido a la pantalla de inicio

---

## 🎬 Qué Esperar

### ✅ Si funciona correctamente:

1. Click en botón Google → Popup se abre
2. Seleccionas cuenta → Popup se cierra
3. Redirige a Home Screen
4. Ves tu nombre y foto de perfil de Google

### ❌ Si NO está habilitado en Firebase:

```
Error: [firebase_auth/operation-not-allowed]
The identity provider configuration is not found.
```

**Solución:** Completa los pasos de arriba en Firebase Console

### ⚠️ Si Chrome bloquea el popup:

```
Error: popup_blocked_by_browser
```

**Solución:** 
1. Click en el icono de popup bloqueado en la barra de direcciones
2. "Permitir ventanas emergentes de localhost"
3. Intenta de nuevo

---

## 🔍 Verificar que Funciona

### En Firebase Console:

1. Ve a **Authentication → Users**
2. Deberías ver tu usuario con:
   - ✅ Nombre de Google
   - ✅ Email de Google
   - ✅ Foto de perfil
   - ✅ Provider: `google.com`

### En la App:

1. Home Screen muestra tu información
2. Puedes navegar normalmente
3. Al cerrar sesión, vuelve al login

---

## 📸 Screenshots Esperados

### Antes del Login:
```
┌───────────────────────────────┐
│     EVM CURSOS APP            │
│     ─────────────────         │
│                               │
│  Iniciar Sesión               │
│                               │
│  Email: [____________]        │
│  Pass:  [____________]        │
│                               │
│  [   Iniciar Sesión   ]       │
│                               │
│          ───O───              │
│                               │
│  [G] Continuar con Google     │ ← NUEVO
│                               │
│  ¿No tienes cuenta? Regístrate│
└───────────────────────────────┘
```

### Popup de Google:
```
┌───────────────────────────────┐
│  Elige una cuenta             │
│                               │
│  ┌─────────────────────────┐ │
│  │ 👤 Juan Luna             │ │
│  │    juan@gmail.com        │ │
│  └─────────────────────────┘ │
│                               │
│  ┌─────────────────────────┐ │
│  │ 👤 Otra Cuenta           │ │
│  │    otra@gmail.com        │ │
│  └─────────────────────────┘ │
└───────────────────────────────┘
```

### Después del Login:
```
┌───────────────────────────────┐
│  👤 Bienvenido, Juan Luna     │
│                               │
│  📚 Mis Cursos                │
│  📊 Estadísticas              │
│  🚪 Cerrar Sesión             │
└───────────────────────────────┘
```

---

## 🛠️ Troubleshooting

### Problema: "El botón no hace nada"

1. Abre DevTools (F12)
2. Ve a la pestaña Console
3. Busca errores en rojo
4. Si ves `operation-not-allowed`, habilita Google en Firebase

### Problema: "Popup se cierra inmediatamente"

1. Verifica que `localhost` esté en dominios autorizados
2. Espera 5 minutos después de habilitar Google
3. Refresca la página (Ctrl+R)

### Problema: "Error de red"

1. Verifica tu conexión a internet
2. Intenta en modo incógnito
3. Limpia caché del navegador

---

## 💡 Tips

- **Usa tu cuenta Google personal** para pruebas
- **No cierres el popup manualmente**, déjalo completar
- **Si falla**, espera 10 segundos e intenta de nuevo
- **Revisa la consola** de Chrome para ver logs

---

## 🎉 Cuando Funcione

**Felicidades!** Ya tienes:
- ✅ Autenticación con Email/Password
- ✅ Autenticación con Google
- ✅ Verificación de email
- ✅ Recuperación de contraseña
- ✅ App corriendo en Chrome

**Próximos pasos:**
1. Aplicar reglas de Firestore
2. Implementar subida de materiales
3. Crear banco de preguntas
4. Sistema de evaluaciones

---

**Tiempo estimado:** 1-2 minutos para habilitar + 30 segundos para probar

**Dificultad:** ⭐☆☆☆☆ (Muy fácil)

**Resultado:** Autenticación completa con Google ✨

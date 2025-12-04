# 📚 INSTRUCCIONES DE CONFIGURACIÓN - EVM CURSOS APP

## Paso 1: Configurar Firebase

### 1.1 Crear Proyecto en Firebase

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Clic en "Agregar proyecto"
3. Nombre del proyecto: `evm-cursos-app` (o el que prefieras)
4. Deshabilitar Google Analytics (opcional)
5. Clic en "Crear proyecto"

### 1.2 Habilitar Autenticación

1. En el menú izquierdo, ir a **Authentication**
2. Clic en "Comenzar"
3. En la pestaña "Sign-in method", habilitar:
   - **Email/Password** → Activar
   - Guardar

### 1.3 Crear Base de Datos Firestore

1. En el menú izquierdo, ir a **Firestore Database**
2. Clic en "Crear base de datos"
3. Seleccionar "Comenzar en modo de producción"
4. Elegir ubicación (preferiblemente cercana a tu región)
5. Clic en "Habilitar"

### 1.4 Configurar Reglas de Firestore

En la pestaña **Reglas**, reemplazar con:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /cursos/{cursoId} {
      allow read, write: if request.auth != null && 
                         request.auth.uid == resource.data.usuarioId;
      allow create: if request.auth != null;
    }
    
    match /temas/{temaId} {
      allow read, write: if request.auth != null;
    }
    
    match /materiales/{materialId} {
      allow read, write: if request.auth != null;
    }
    
    match /preguntas/{preguntaId} {
      allow read, write: if request.auth != null;
    }
    
    match /evaluaciones/{evaluacionId} {
      allow read: if request.auth != null && 
                   request.auth.uid == resource.data.usuarioId;
      allow create: if request.auth != null;
    }
  }
}
```

Clic en **Publicar**

### 1.5 Configurar Storage

1. En el menú izquierdo, ir a **Storage**
2. Clic en "Comenzar"
3. Aceptar las reglas por defecto
4. Elegir ubicación (la misma que Firestore)
5. Clic en "Listo"

### 1.6 Configurar Reglas de Storage

En la pestaña **Reglas**, reemplazar con:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /cursos/{cursoId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

Clic en **Publicar**

## Paso 2: Configurar FlutterFire

### 2.1 Instalar FlutterFire CLI

Abrir terminal en Windows PowerShell:

```powershell
dart pub global activate flutterfire_cli
```

### 2.2 Configurar el Proyecto

```powershell
cd d:\proyectos\evm_cursos_app
flutterfire configure
```

Seguir las instrucciones:
1. Seleccionar el proyecto de Firebase que creaste
2. Seleccionar las plataformas (Windows, Web, Android, iOS, macOS)
3. Esperar a que se genere `firebase_options.dart`

## Paso 3: Verificar Instalación

### 3.1 Verificar Dependencias

```powershell
flutter pub get
```

### 3.2 Listar Dispositivos

```powershell
flutter devices
```

Deberías ver algo como:
```
Windows (desktop) • windows • windows-x64
Chrome (web)      • chrome  • web-javascript
Edge (web)        • edge    • web-javascript
```

## Paso 4: Ejecutar la Aplicación

### 4.1 En Windows

```powershell
flutter run -d windows
```

### 4.2 En Web (Chrome)

```powershell
flutter run -d chrome
```

### 4.3 En Web (Edge)

```powershell
flutter run -d edge
```

## Paso 5: Probar la Aplicación

### 5.1 Registro de Usuario

1. La app se abrirá en la pantalla de Login
2. Clic en "Regístrate"
3. Ingresar:
   - Email: tu-email@ejemplo.com
   - Contraseña: mínimo 6 caracteres
4. Clic en "Registrarse"

### 5.2 Verificar Email

1. Revisar tu bandeja de entrada
2. Buscar el correo de verificación de Firebase
3. Clic en el enlace de verificación
4. Volver a la app
5. Clic en "Verificar Email"

### 5.3 Crear Curso

1. Una vez verificado el email, accederás al Home
2. Clic en "Nuevo Curso"
3. Llenar:
   - Título: "Matemáticas Básicas"
   - Descripción: "Curso de matemáticas para principiantes"
   - Categoría: "Matemáticas"
4. Clic en "Crear Curso"

### 5.4 Crear Tema

1. Clic en el curso creado
2. Clic en "Nuevo Tema"
3. Llenar:
   - Nombre: "Suma y Resta"
   - Descripción: "Operaciones básicas"
   - Orden: 1
4. Clic en "Crear Tema"

## Solución de Problemas Comunes

### Error: "Firebase not initialized"

**Solución:**
```powershell
cd d:\proyectos\evm_cursos_app
flutterfire configure
```

### Error: "No devices available"

**Solución:**
```powershell
# Verificar Flutter
flutter doctor

# Si falta alguna herramienta, instalarla según las instrucciones
```

### Error: Compilación en Windows

**Solución:**
```powershell
flutter clean
flutter pub get
flutter run -d windows
```

### Email de verificación no llega

**Solución:**
1. Revisar carpeta de Spam
2. En Firebase Console → Authentication → Templates
3. Verificar que la plantilla de verificación esté activa
4. En la app, usar "Reenviar Correo"

### Error: PERMISSION_DENIED en Firestore

**Solución:**
1. Verificar que las reglas de Firestore estén correctamente configuradas
2. Verificar que el usuario esté autenticado
3. Verificar que el email esté verificado

## Estructura de Datos en Firestore

### Colección: `cursos`
```json
{
  "titulo": "string",
  "descripcion": "string",
  "categoria": "string",
  "usuarioId": "string",
  "fechaCreacion": "timestamp"
}
```

### Colección: `temas`
```json
{
  "cursoId": "string",
  "nombre": "string",
  "descripcion": "string",
  "orden": "number",
  "fechaCreacion": "timestamp"
}
```

### Colección: `materiales`
```json
{
  "temaId": "string",
  "nombre": "string",
  "descripcion": "string",
  "tipo": "pdf | video",
  "urlArchivo": "string",
  "fechaSubida": "timestamp"
}
```

### Colección: `preguntas`
```json
{
  "temaId": "string",
  "enunciado": "string",
  "tipo": "seleccionMultiple | verdaderoFalso",
  "opciones": ["array", "of", "strings"],
  "respuestaCorrecta": "string",
  "fechaCreacion": "timestamp"
}
```

### Colección: `evaluaciones`
```json
{
  "usuarioId": "string",
  "temaId": "string",
  "cursoId": "string",
  "puntajeObtenido": "number",
  "puntajeTotal": "number",
  "porcentaje": "number",
  "duracionSegundos": "number",
  "fechaRealizacion": "timestamp",
  "respuestasUsuario": {
    "preguntaId": "respuesta"
  }
}
```

## Comandos Útiles

```powershell
# Ver dispositivos disponibles
flutter devices

# Limpiar proyecto
flutter clean

# Actualizar dependencias
flutter pub get

# Ejecutar en Windows
flutter run -d windows

# Ejecutar en Chrome
flutter run -d chrome

# Ver logs
flutter logs

# Crear build de release para Windows
flutter build windows --release

# Analizar código
flutter analyze

# Formatear código
dart format lib/
```

## Próximos Pasos

Después de configurar exitosamente:

1. ✅ Probar registro y login
2. ✅ Crear al menos 2 cursos
3. ✅ Crear al menos 2 temas por curso
4. ⏳ Implementar funcionalidad de materiales (PDF/Video)
5. ⏳ Implementar banco de preguntas
6. ⏳ Implementar sistema de evaluaciones
7. ⏳ Implementar estadísticas y gráficos

## Contacto y Soporte

Si encuentras problemas:
1. Revisar esta guía completa
2. Verificar la consola de Firebase
3. Revisar los logs de Flutter: `flutter logs`
4. Verificar que todas las dependencias estén instaladas: `flutter doctor`

---

**Proyecto**: EVM Cursos App - Caso 1  
**Framework**: Flutter + Firebase  
**Plataformas**: Windows, Web, Android, iOS, macOS

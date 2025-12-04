# EVM Cursos App - Caso 1
## Sistema de Gestión de Cursos con Evaluaciones

### 📋 Descripción
Aplicación móvil multiplataforma desarrollada con Flutter y Firebase para la gestión personalizada de cursos, material de estudio y evaluaciones.

### 🎯 Características Principales

#### 1. Autenticación y Registro
- ✅ Registro de usuarios con correo electrónico
- ✅ Validación obligatoria de email
- ✅ Inicio de sesión seguro
- ✅ Recuperación de contraseña
- ✅ Pantalla de verificación de email

#### 2. Gestión de Cursos
- ✅ Crear cursos personalizados (título, descripción, categoría)
- ✅ Editar cursos existentes
- ✅ Eliminar cursos
- ✅ Vista de lista de todos los cursos

#### 3. Organización del Contenido
- ✅ Crear temas/unidades por curso
- ✅ Editar y eliminar temas
- ⏳ Subir material de estudio (PDF/Video)
- ⏳ Almacenamiento en Firebase Storage

#### 4. Sistema de Evaluación
- ⏳ Banco de preguntas por tema
- ⏳ Tipos de preguntas (selección múltiple, verdadero/falso)
- ⏳ Evaluaciones aleatorias
- ⏳ Cronómetro opcional
- ⏳ Calificación automática
- ⏳ Resultados inmediatos

#### 5. Estadísticas y Progreso
- ⏳ Historial de evaluaciones
- ⏳ Gráficos de rendimiento
- ⏳ Progreso por curso

### 🔧 Configuración Rápida

1. **Instalar dependencias**
   ```bash
   cd d:/proyectos/evm_cursos_app
   flutter pub get
   ```

2. **Configurar Firebase**
   ```bash
   # Instalar FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configurar proyecto
   flutterfire configure
   ```

3. **Ejecutar la app**
   ```bash
   flutter run -d windows
   ```

### 📝 Nomenclatura (Iniciales: EVM)

- **Clases**: `EVMCLSNombre`
- **Servicios**: `EVMNombreService`  
- **Pantallas**: `EVMNombreScreen`

### 📱 Plataformas Soportadas

✅ Windows | ✅ Web | ✅ Android | ✅ iOS | ✅ macOS

---
**Desarrollador**: EVM | **Framework**: Flutter + Firebase

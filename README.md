# BarrioSeguro - Aplicación Ciudadana de Seguridad

**Versión:** 0.1.0 | **Tipo:** Prototipo de Simulación (Mock Data)

---

## 📱 Descripción

**BarrioSeguro** es una aplicación móvil Flutter completamente funcional diseñada como prototipo de simulación para reportes colaborativos de seguridad ciudadana. La app permite a los ciudadanos:

- 🚨 Reportar incidentes de seguridad (robo, accidente, persona sospechosa, daño vial)
- 🆘 Enviar SOS de emergencia con un toque
- 📍 Ver alertas en su barrio en tiempo real (simulado)
- 👤 Proteger su identidad con pseudónimo UUID
- 📊 Mantener historial de reportes

### Características Clave

✅ **Arquitectura Clean Architecture** - Separación completa de capas (Domain/Infrastructure/Presentation)  
✅ **Riverpod 3.0** - Manejo de estado moderno y declarativo  
✅ **GoRouter** - Navegación declarativa con rutas tipadas  
✅ **Tema Oscuro** - Interfaz moderna con Material Design 3  
✅ **100% Mock Data** - Sin APIs externas ni backend requerido  
✅ **Validaciones Locales** - Formularios con retroalimentación inmediata  
✅ **Animaciones Fluidas** - flutter_animate para transiciones suaves

---

## 🏗️ Arquitectura de Carpetas

```
lib/
├── core/
│   ├── errors/
│   │   ├── failures.dart          # Clases base de errores
│   │   └── exceptions.dart        # Excepciones personalizadas
│   ├── network/
│   │   └── network_info.dart      # Mock de estado de red
│   └── utils/
│       ├── app_colors.dart        # Paleta de colores
│       ├── app_theme.dart         # Tema Material 3 oscuro
│       └── app_router.dart        # Rutas GoRouter
│
├── features/
│   ├── auth/                      # Autenticación
│   │   ├── domain/
│   │   │   ├── entities/user_entity.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/
│   │   ├── infrastructure/
│   │   │   ├── datasources/auth_local_datasource.dart
│   │   │   ├── models/user_model.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/auth_provider.dart
│   │       ├── pages/
│   │       │   ├── splash_page.dart
│   │       │   ├── onboarding_page.dart
│   │       │   └── auth_page.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           ├── register_form.dart
│   │           └── privacy_badge_widget.dart
│   │
│   ├── reports/                   # Reportes y alertas
│   │   ├── domain/
│   │   │   ├── entities/report_entity.dart
│   │   │   ├── repositories/reports_repository.dart
│   │   │   └── usecases/
│   │   ├── infrastructure/
│   │   │   ├── datasources/reports_local_datasource.dart
│   │   │   ├── models/report_model.dart
│   │   │   └── repositories/reports_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/reports_provider.dart
│   │       ├── pages/
│   │       │   ├── home_page.dart
│   │       │   ├── report_page.dart
│   │       │   └── history_page.dart
│   │       └── widgets/
│   │           ├── sos_button_widget.dart
│   │           ├── report_card_widget.dart
│   │           ├── incident_type_chips.dart
│   │           └── offline_banner_widget.dart
│   │
│   └── map/                       # Mapa de alertas
│       ├── domain/
│       │   ├── entities/map_marker_entity.dart
│       │   ├── repositories/map_repository.dart
│       │   └── usecases/get_map_markers_usecase.dart
│       ├── infrastructure/
│       │   ├── datasources/map_local_datasource.dart
│       │   └── repositories/map_repository_impl.dart
│       └── presentation/
│           ├── providers/map_provider.dart
│           ├── pages/map_page.dart
│           └── widgets/
│               ├── mock_map_painter.dart
│               └── map_legend_widget.dart
│
└── main.dart                      # Entry point
```

---

## 🎨 Diseño y Tema

### Paleta de Colores

| Color | Uso | Hex |
|-------|-----|-----|
| Azul Eléctrico | Primario | `#1E90FF` |
| Rojo | SOS/Error | `#FF3B30` |
| Verde | Éxito | `#34C759` |
| Naranja | Advertencia | `#FF9500` |
| Fondo | Background | `#0D0D0D` |
| Superficie | Surface | `#1C1C1E` |
| Card | Card | `#2C2C2E` |

### Tipografía

- **Títulos/Display:** Google Fonts "Outfit" (Bold, 600)
- **Cuerpo:** Google Fonts "DM Sans" (Regular, 400)

### Material Design 3

- Modo oscuro activado por defecto
- `useMaterial3: true`
- Animaciones suaves con flutter_animate

---

## 📱 Flujo de Pantallas

```
SplashPage (2s)
    ↓
OnboardingPage (3 slides con PageView)
    ↓
AuthPage (Login | Register tabs)
    ├→ LoginForm (alias + contraseña)
    ├→ RegisterForm (alias + contraseña + barrio)
    └→ Login as Visitor Button
    ↓
HomePage (tabs: Home | Report | Map | History)
    ├→ SOS Button (Emergencia)
    ├→ Recent Alerts (Mock cards)
    └→ Bottom Nav
    ↓
ReportPage (3-step Stepper)
    ├→ Step 1: Seleccionar tipo
    ├→ Step 2: Descripción + GPS
    └→ Step 3: Confirmar y enviar
    ↓
MapPage (CustomPaint + Mock Markers)
    └→ Leyenda de colores
    ↓
HistoryPage (ListView de reportes del usuario)
    └→ Bloqueado para visitantes
```

---

## 🔌 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1        # Tipografía custom
  go_router: ^13.2.0          # Enrutamiento declarativo
  flutter_riverpod: ^3.0.0    # Estado reactivo
  flutter_animate: ^4.5.0     # Animaciones
  uuid: ^4.4.0                # Generación de UUIDs v4
  intl: ^0.19.0               # Internacionalización
```

---

## 🚀 Cómo Ejecutar

### Requisitos

- Flutter 3.10+
- Dart 3.10+
- iOS/Android emulator o device físico

### Pasos

```bash
# 1. Obtener dependencias
flutter pub get

# 2. Ejecutar en emulator/device
flutter run

# 3. (Opcional) Ejecutar análisis
flutter analyze

# 4. (Opcional) Ejecutar con profiler
flutter run --profile
```

---

## ✨ Funcionalidades del Prototipo

### [SPLASH]
- Animación de entrada con fade + scale
- Delay de 2s antes de navegar a onboarding

### [ONBOARDING]
- PageView de 3 slides
- Indicadores de progreso (dots)
- Botón "Saltar" (slides 1-2)
- Botón "Comenzar" (slide 3)

### [AUTH - LOGIN]
- TextFormField para alias
- TextFormField para contraseña (toggle visibilidad)
- Validación: campos no vacíos
- Cualquier alias + password no vacío = éxito
- Navegación a /home

### [AUTH - REGISTER]
- TextFormField: alias
- TextFormField: contraseña
- DropdownButtonFormField: barrio (opciones: Norte, Sur, Centro, Este, Oeste)
- TextFormField: teléfono (opcional)
- Generación de UUID v4
- Dialog con UUID privado antes de navegar
- Almacenamiento local en memoria

### [AUTH - VISITANTE]
- Botón "Ingresar como Visitante"
- Genera pseudo-usuario con isVisitor: true
- Puede ver reportes y mapa
- Historial bloqueado

### [HOME]
- AppBar con nombre de usuario
- Banner offline (si isOffline == true)
- SOS Button circular con pulso (escala 1.0 → 1.08)
  - Confirmación antes de enviar
  - Simulación 1.5s
  - SnackBar de éxito
- Sección "Alertas en tu barrio" con 3 report cards
- FAB para nuevo reporte
- Bottom Navigation 4 tabs

### [REPORT - STEPPER]
- **Paso 1 - Tipo:** FilterChips (Robo, Accidente, Sospechoso, Daño vial, Otro)
- **Paso 2 - Descripción:** 
  - TextFormField multiline (max 280 caracteres)
  - GPS simulado: -2.1234, -79.5678
  - Switch para adjuntar foto/video
  - Container gris si activa: "📷 Cámara no disponible en demo"
- **Paso 3 - Confirmar:**
  - Resumen de datos
  - Botón "Enviar Reporte"
  - Progreso circular (1.5s)
  - SnackBar en Home + navega a /home

### [MAP]
- CustomPaint con grilla de calles (#1a2332, líneas gris #2A3F5F)
- Bloques de manzanas simulados
- 5 Markers mock (2 emergencia rojo, 2 alerta naranja, 1 incidente azul)
- Badge de radio ("📍 Radio: 3km")
- Leyenda con colores
- Tap en marker → dialog con detalles

### [HISTORY]
- Si visitante: Icon de lock + "Inicia sesión"
- Si autenticado: ListView de reportes del usuario
- RefreshIndicator simulado (delay 1s)
- Report cards con timestamp y estado
- Empty state si no hay reportes

---

## 🧪 Modo Offline

- Toggle en AppBar de HomePage
- Si activo: muestra OfflineBannerWidget (rojo)
- SOS Button muestra SnackBar: "📴 SOS guardado localmente. Se enviará al reconectar"
- Todos los datos se mantienen en memoria

---

## 📊 Datos Mock

### Reportes del Barrio (getRecentReports)
- 4 reportes predefinidos
- Tipos variados: robo, accidente, sospechoso, daño vial
- Estados: recibido, en_revision, atendido
- Timestamps relativos (15 min, 45 min, 2h, 3h atrás)

### Reportes del Usuario (getUserHistory)
- Generados dinámicamente al acceder
- 3 reportes iniciales por usuario
- Almacenados en mapa local por UUID

### Marcadores de Mapa (getMapMarkers)
- 5 marcadores: 2 emergencia, 2 alerta, 1 incidente menor
- Coordenadas simuladas en barrio ficticio
- Descripciones detalladas

---

## 🔐 Seguridad y Privacidad

- ✅ **Sin APIs externas** - 100% local
- ✅ **UUID v4 como pseudónimo** - identidad protegida
- ✅ **Sin datos sensibles en logs** - validaciones locales
- ✅ **Sin geolocalización real** - GPS simulado

---

## ⚡ Performance

- **Análisis en tiempo real:** flutter analyze (32 warnings, 0 errors)
- **Compilación exitosa:** ✓
- **Tamaño de bundle:** Mínimo (solo mock data)
- **Memoria:** Almacenamiento local en memoria
- **Animaciones:** 60 FPS (flutter_animate)

---

## 📝 Notas Técnicas

### Riverpod v3
- Usamos `Notifier<T>` para estado mutable
- `FutureProvider` para operaciones async
- Providers composables y reutilizables

### GoRouter
- Rutas declarativas: /splash → /onboarding → /auth → /home
- Sub-rutas: /report, /history, /map
- Transiciones suaves

### Clean Architecture
- **Domain:** Entidades, repositorios (interfaces), usecases
- **Infrastructure:** Modelos, datasources, implementaciones
- **Presentation:** Providers, páginas, widgets

### Testing
No incluye tests (prototipo), pero la arquitectura es 100% testeable

---

## 🎯 Siguientes Pasos (Futuro)

- [ ] Integración con API real
- [ ] Geolocalización real (google_maps_flutter)
- [ ] Cámara y galería (image_picker)
- [ ] Almacenamiento local persistente (sqflite/hive)
- [ ] Autenticación real (Firebase Auth)
- [ ] Push notifications
- [ ] Tests unitarios y widget tests
- [ ] Internacionalización (es/en)
- [ ] Análisis de datos y reportes

---

## 📄 Licencia

Proyecto de demostración - BarrioSeguro Prototype v0.1.0

---

**Creado con ❤️ usando Flutter y Clean Architecture**

# 🕷️ Spider-Man 2D — City Strike

Un videojuego Shooter Top-Down 2D inspirado en Spider-Man, construido completamente con **Flutter y Dart puro** sin motores externos. Todo el renderizado es procedural usando `CustomPainter` y `Canvas`.

---

## 🎮 Características

- **Vista top-down 2D** con sprites procedurales (sin assets externos)
- **Spider-Man** como personaje jugable con traje rojo y azul
- **3 villanos** de Marvel:
  - 🟢 **Green Goblin** (rápido, lanza bombas, ataques a distancia)
  - 🔘 **Rhino** (lento, enorme vida, cuerpo a cuerpo)
  - 🦅 **Vulture** (volador, vida media, ataques a distancia)
- **3 armas** tipo Web Shooter:
  - **Web Shot** — disparo básico, munición infinita
  - **Web Burst** — spread de 5 hilos
  - **Impact Web** — disparo rápido
- **3 zonas** con dificultad creciente:
  - Zona 1: Daily Bugle Rooftop
  - Zona 2: Oscorp Tower
  - Zona 3: Villain's Lair
- **Controles táctiles**: Joystick virtual + botones de acción
- **HUD estilo DOOM**: vida, munición, puntuación, minimapa
- **Efectos visuales**: partículas web, flash de daño, glow en proyectiles
- **Sistema de colisiones AABB/Círculo** sin motor físico externo
- **Puertas** que se abren automáticamente al acercarse

---

## 📋 Requisitos Previos

1. **Flutter SDK** (versión 3.0+)
   - Instalar desde: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. **Android Studio** o un dispositivo Android físico
3. **Git** (opcional, para clonar)

---

## 🚀 Instalación y Ejecución

```bash
# 1. Entrar al directorio
cd spiderman_2d

# 2. Instalar dependencias (solo Flutter SDK)
flutter pub get

# 3. Verificar entorno
flutter doctor

# 4. Correr en modo debug (emulador o dispositivo conectado)
flutter run

# 5. Compilar APK release 
flutter build apk --release
```

El APK se genera en: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Controles

| Control | Acción |
|---------|--------|
| **Joystick izquierdo (rojo)** | Mover a Spider-Man |
| **Botón azul (derecha)** | Disparar telaraña (mantener) |
| **Botón naranja (derecha)** | Cambiar arma |

---

## 🎯 Cómo Jugar

1. Elimina **todos los villanos** en la zona
2. La **salida** (símbolo de telaraña verde) se desbloquea al eliminar todos
3. Camina sobre la salida para avanzar a la siguiente zona
4. Recoge **vida (+)** y **munición (W)** en el camino
5. Consigue el **Web Burst (B)** para disparo en área
6. ¡Completa las 3 zonas para salvar la ciudad!

---

## 🏗️ Cómo se implementó el Game Loop

El motor del juego usa el `Ticker` de Flutter para ejecutar el bucle de juego a ~60 FPS:

```dart
_ticker = createTicker(_onTick);
_ticker.start();

void _onTick(Duration elapsed) {
  double dt = (elapsed - _lastTick).inMicroseconds / 1_000_000.0;
  if (dt > 0.05) dt = 0.05; // Cap para evitar explosiones físicas
  engine.update(dt);         // Actualiza toda la lógica
  setState(() {});           // Dispara repintado del CustomPainter
}
```

Cada frame, `GameEngine.update(dt)` actualiza en orden:
1. Posición del jugador + colisión con paredes
2. Armas y proyectiles
3. IA de enemigos (persecución + ataque)
4. Colisiones proyectil↔enemigo, proyectil↔jugador
5. Daño por contacto
6. Pickups
7. Puertas automáticas
8. Estado del nivel (¿completado? ¿game over?)
9. Partículas

---

## 🗂️ Estructura del Proyecto

```
lib/
├── main.dart                    # Entry point — Game Loop (Ticker)
├── game/
│   ├── game_engine.dart         # Motor: estados, update, colisiones
│   ├── player.dart              # Spider-Man: movimiento, vida, armas
│   ├── enemy.dart               # Clase base villanos (IA persecución)
│   ├── enemy_types.dart         # Goblin, Rhino, Vulture
│   ├── projectile.dart          # Web Shot, Web Burst, Impact Web
│   ├── weapon.dart              # Sistema de armas y cadencia
│   ├── pickup.dart              # Items recolectables
│   ├── game_map.dart            # Mapa de tiles
│   ├── levels.dart              # 3 zonas predefinidas (30x20 tiles)
│   └── collision.dart           # AABB/círculo: paredes, enemigos, pickups
├── rendering/
│   ├── game_renderer.dart       # CustomPainter principal + cámara + minimap
│   ├── sprite_painter.dart      # Sprites procedurales: Spider-Man, Goblin, Rhino, Vulture
│   └── effects.dart             # Partículas, flash daño, salida web
├── ui/
│   ├── hud.dart                 # Vida, munición, score, zona
│   ├── touch_controls.dart      # Joystick virtual + botones
│   ├── main_menu.dart           # Menú animado con web background
│   └── game_over_screen.dart    # Game Over / Victoria / Zona completa
└── utils/
    ├── constants.dart           # Constantes de juego + paleta Spider-Man
    └── audio_manager.dart       # Placeholder audio (listo para integrar)
```

---

## ❓ Preguntas frecuentes (ExpoGo)

**¿Cómo maneja las colisiones sin motor físico?**
Se usa detección AABB (circle-vs-rect) para jugador↔paredes y círculo↔círculo para entidades. Ver `collision.dart`.

**¿Cómo optimiza el renderizado en CustomPainter?**
Solo se renderizan los tiles visibles en pantalla (frustum culling por rangos de columna/fila). `shouldRepaint` retorna `true` siempre porque el juego cambia cada frame.

**¿Cómo gestiona el estado global?**
`GameEngine` es la única fuente de verdad. El widget raíz `_GameScreenState` recibe callbacks de los controles, los pasa al engine, y llama `setState()` en cada tick para disparar el repintado.

---

## 📝 Licencia

Proyecto educativo — Desarrollo de Aplicaciones Móviles (Flutter & Dart).
Inspirado en Spider-Man de Marvel Comics y DOOM de id Software.

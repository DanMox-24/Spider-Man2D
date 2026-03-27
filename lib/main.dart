import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/game_engine.dart';
import 'rendering/game_renderer.dart';
import 'ui/hud.dart';
import 'ui/touch_controls.dart';
import 'ui/main_menu.dart';
import 'ui/game_over_screen.dart';
import 'utils/constants.dart';
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const SpiderMan2DApp());
}

class SpiderMan2DApp extends StatelessWidget {
  const SpiderMan2DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spider-Man 2D',
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData.dark().copyWith(scaffoldBackgroundColor: DoomColors.menuBg),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameEngine engine;
  late Ticker _ticker;
  double _totalTime = 0;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    engine = GameEngine();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  /// Game Loop principal con ticker de Flutter para actualizar el estado del juego y renderizar cada frame
  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }

    double dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;
    if (dt > 0.05) dt = 0.05; // cap para evitar explosión de física

    _totalTime += dt;

    for (var pickup in engine.currentMap.pickups) {
      pickup.update(dt);
    }

    engine.update(dt);
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    engine.audio.dispose();
    super.dispose();
  }

  void _onMove(double dx, double dy) {
    engine.player.moveX = dx;
    engine.player.moveY = dy;
  }

  void _onShoot(bool s) => engine.player.isShooting = s;
  void _onSwitchWeapon() => engine.player.switchWeapon();
  void _startNewGame() {
    engine.startNewGame();
    setState(() {});
  }

  void _goToMenu() {
    engine.state = GameState.menu;
    setState(() {});
  }

  void _nextLevel() {
    engine.nextLevel();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Menú principal ───────────────────────────────────────────────
          if (engine.state == GameState.menu)
            MainMenuScreen(onStartGame: _startNewGame),

          // ── Canvas del juego ─────────────────────────────────────────────
          if (engine.state == GameState.playing ||
              engine.state == GameState.levelComplete ||
              engine.state == GameState.gameOver ||
              engine.state == GameState.victory) ...[
            Positioned.fill(
              child: CustomPaint(
                painter: GameRenderer(engine: engine, time: _totalTime),
                child: Container(),
              ),
            ),
            if (engine.state == GameState.playing) HudOverlay(engine: engine),
            if (engine.state == GameState.playing)
              TouchControls(
                  onMove: _onMove,
                  onShoot: _onShoot,
                  onSwitchWeapon: _onSwitchWeapon),
          ],

          // ── Zona completada ───────────────────────────────────────────────
          if (engine.state == GameState.levelComplete)
            LevelCompleteScreen(
              level: engine.currentLevel,
              kills: engine.killCount,
              score: engine.player.score,
              onNextLevel: _nextLevel,
            ),

          // ── Game Over / Victoria ──────────────────────────────────────────
          if (engine.state == GameState.gameOver ||
              engine.state == GameState.victory)
            GameOverScreen(
              score: engine.player.score,
              level: engine.currentLevel,
              kills: engine.totalKills + engine.killCount,
              isVictory: engine.state == GameState.victory,
              onRestart: _startNewGame,
              onMenu: _goToMenu,
            ),
        ],
      ),
    );
  }
}

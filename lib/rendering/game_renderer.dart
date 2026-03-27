import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../game/game_engine.dart';
import '../game/game_map.dart';
import '../game/player.dart';

import '../game/enemy_types.dart';

import 'sprite_painter.dart';
import 'effects.dart';

/// Renderizador principal del juego — CustomPainter con cámara centrada en jugador
class GameRenderer extends CustomPainter {
  final GameEngine engine;
  final double time;

  GameRenderer({required this.engine, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final player = engine.player;
    final map = engine.currentMap;

    // Cámara centrada en el jugador
    double camX = player.x - size.width / 2;
    double camY = player.y - size.height / 2;
    camX = camX.clamp(
        0.0, (map.pixelWidth - size.width).clamp(0.0, double.infinity));
    camY = camY.clamp(
        0.0, (map.pixelHeight - size.height).clamp(0.0, double.infinity));

    canvas.save();

    // Fondo oscuro ciudad noche
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = DoomColors.floor,
    );

    canvas.translate(-camX, -camY);

    int startCol =
        ((camX / GameConstants.tileSize).floor() - 1).clamp(0, map.width - 1);
    int endCol = (((camX + size.width) / GameConstants.tileSize).floor() + 1)
        .clamp(0, map.width - 1);
    int startRow =
        ((camY / GameConstants.tileSize).floor() - 1).clamp(0, map.height - 1);
    int endRow = (((camY + size.height) / GameConstants.tileSize).floor() + 1)
        .clamp(0, map.height - 1);

    _drawFloor(canvas, startCol, endCol, startRow, endRow, engine.currentLevel);

    // Salida
    bool allDead = engine.enemiesRemaining == 0;
    EffectsRenderer.drawExitTile(canvas, map.exitX, map.exitY, time, allDead);

    // Paredes
    _drawWalls(
        canvas, map, startCol, endCol, startRow, endRow, engine.currentLevel);

    // Pickups
    for (var pickup in map.pickups) {
      if (!pickup.isActive) continue;
      SpritePainter.drawPickup(
          canvas, pickup.x, pickup.y, pickup.type, pickup.bobTimer);
    }

    // Enemigos
    for (var enemy in map.enemies) {
      if (!enemy.isActive) continue;

      if (enemy is RhinoBoss) {
        SpritePainter.drawRhino(canvas, enemy.x, enemy.y, enemy.angle,
            enemy.healthPercent, enemy.state, time);
      } else if (enemy is VultureBoss) {
        SpritePainter.drawVultureBoss(canvas, enemy.x, enemy.y, enemy.angle,
            enemy.healthPercent, enemy.state, time);
      } else if (enemy is VenomBoss) {
        SpritePainter.drawVenom(canvas, enemy.x, enemy.y, enemy.angle,
            enemy.healthPercent, enemy.state, time);
      } else if (enemy is Imp) {
        SpritePainter.drawImp(canvas, enemy.x, enemy.y, enemy.angle,
            enemy.healthPercent, enemy.state);
      } else if (enemy is Demon) {
        SpritePainter.drawDemon(canvas, enemy.x, enemy.y, enemy.angle,
            enemy.healthPercent, enemy.state);
      } else {
        SpritePainter.drawImp(canvas, enemy.x, enemy.y, enemy.angle,
            enemy.healthPercent, enemy.state);
      }
    }

    // Proyectiles
    for (var proj in engine.projectiles) {
      if (!proj.isActive) continue;
      SpritePainter.drawProjectile(
        canvas,
        proj.x,
        proj.y,
        proj.isPlayerBullet,
        proj.weaponType,
        isVenom: proj.isVenom,
      );
    }

    // Partículas
    EffectsRenderer.drawParticles(canvas, engine.particles);

    // Spider-Man
    SpritePainter.drawPlayer(
      canvas,
      player.x,
      player.y,
      player.angle,
      player.isInvulnerable,
      time,
      player.currentWeapon,
    );

    canvas.restore();

    // Flash de daño (pantalla completa, sin cámara)
    EffectsRenderer.drawDamageFlash(canvas, size, player.damageFlashTimer);

    // Minimapa
    _drawMinimap(canvas, size, map, player);
  }

  // ─── Suelo con patrón por nivel ──────────────────────────────────────────
  void _drawFloor(Canvas canvas, int startCol, int endCol, int startRow,
      int endRow, int level) {
    final ts = GameConstants.tileSize;

    // Colores base por nivel
    Color c1, c2;
    switch (level) {
      case 1: // Oscorp: verde oscuro
        c1 = const Color(0xFF1B2A1B);
        c2 = const Color(0xFF162016);
        break;
      case 2: // Guarida Venom: violeta oscuro
        c1 = const Color(0xFF1A1228);
        c2 = const Color(0xFF140D20);
        break;
      default: // Daily Bugle: azul urbano
        c1 = DoomColors.floor;
        c2 = DoomColors.floorAlt;
    }

    final p1 = Paint()..color = c1;
    final p2 = Paint()..color = c2;

    for (int row = startRow; row <= endRow; row++) {
      for (int col = startCol; col <= endCol; col++) {
        canvas.drawRect(
          Rect.fromLTWH(col * ts, row * ts, ts, ts),
          (row + col) % 2 == 0 ? p1 : p2,
        );
      }
    }
  }

  // ─── Paredes con estilo por nivel ─────────────────────────────────────────
  void _drawWalls(Canvas canvas, GameMap map, int startCol, int endCol,
      int startRow, int endRow, int level) {
    final ts = GameConstants.tileSize;

    Color wallColor, detailColor, glowColor;
    switch (level) {
      case 1: // Oscorp: verde metálico
        wallColor = const Color(0xFF263A1C);
        detailColor = const Color(0xFF1A2812);
        glowColor = const Color(0xFF4CAF50);
        break;
      case 2: // Venom: negro violáceo
        wallColor = const Color(0xFF1A0D2E);
        detailColor = const Color(0xFF110820);
        glowColor = DoomColors.venomTentacle;
        break;
      default: // Daily Bugle: azul gris urbano
        wallColor = DoomColors.wallBrown;
        detailColor = DoomColors.wallDark;
        glowColor = DoomColors.hudBorder;
    }

    for (int row = startRow; row <= endRow; row++) {
      for (int col = startCol; col <= endCol; col++) {
        TileType tile = map.getTile(col, row);
        if (tile == TileType.wall) {
          _drawWallTile(canvas, col * ts, row * ts, ts, row, wallColor,
              detailColor, glowColor);
        } else if (tile == TileType.door) {
          _drawDoorTile(canvas, col * ts, row * ts, ts, false);
        } else if (tile == TileType.lockedDoor) {
          _drawDoorTile(canvas, col * ts, row * ts, ts, true);
        }
      }
    }
  }

  void _drawWallTile(Canvas canvas, double x, double y, double size, int row,
      Color wallColor, Color detailColor, Color glowColor) {
    canvas.drawRect(
        Rect.fromLTWH(x, y, size, size), Paint()..color = wallColor);

    final detail = Paint()
      ..color = detailColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(x, y + size / 2), Offset(x + size, y + size / 2), detail);

    double off = (row % 2 == 0) ? size / 2 : 0;
    canvas.drawLine(Offset(x + size / 4 + off, y),
        Offset(x + size / 4 + off, y + size / 2), detail);
    canvas.drawLine(Offset(x + 3 * size / 4 + off, y),
        Offset(x + 3 * size / 4 + off, y + size / 2), detail);

    // Highlight neón según nivel
    canvas.drawLine(
      Offset(x, y + 1),
      Offset(x + size, y + 1),
      Paint()
        ..color = glowColor.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(x, y + size - 1),
      Offset(x + size, y + size - 1),
      Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDoorTile(
      Canvas canvas, double x, double y, double size, bool locked) {
    Color color = locked ? DoomColors.doorLocked : DoomColors.doorColor;
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 2, size - 8, size - 4),
        Paint()..color = color);
    canvas.drawRect(
      Rect.fromLTWH(x + 4, y + 2, size - 8, size - 4),
      Paint()
        ..color = DoomColors.wallLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(x + size * 0.7, y + size / 2),
      3,
      Paint()..color = Colors.yellow.withOpacity(0.8),
    );
    if (locked) {
      canvas.drawCircle(
        Offset(x + size / 2, y + size / 2),
        4,
        Paint()..color = DoomColors.keyPickup,
      );
    }
  }

  // ─── Minimapa ─────────────────────────────────────────────────────────────
  void _drawMinimap(Canvas canvas, Size size, GameMap map, Player player) {
    const double mmScale = 3.0;
    double mmW = map.width * mmScale;
    double mmH = map.height * mmScale;
    double mmX = size.width - mmW - 10;
    double mmY = 10;

    canvas.drawRect(
      Rect.fromLTWH(mmX - 2, mmY - 2, mmW + 4, mmH + 4),
      Paint()..color = Colors.black.withOpacity(0.65),
    );
    canvas.drawRect(
      Rect.fromLTWH(mmX - 2, mmY - 2, mmW + 4, mmH + 4),
      Paint()
        ..color = DoomColors.hudBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final wallP = Paint()..color = DoomColors.wallBrown.withOpacity(0.8);
    final doorP = Paint()..color = DoomColors.doorColor.withOpacity(0.8);

    for (int row = 0; row < map.height; row++) {
      for (int col = 0; col < map.width; col++) {
        TileType tile = map.getTile(col, row);
        if (tile == TileType.wall) {
          canvas.drawRect(
              Rect.fromLTWH(
                  mmX + col * mmScale, mmY + row * mmScale, mmScale, mmScale),
              wallP);
        } else if (tile == TileType.door || tile == TileType.lockedDoor) {
          canvas.drawRect(
              Rect.fromLTWH(
                  mmX + col * mmScale, mmY + row * mmScale, mmScale, mmScale),
              doorP);
        }
      }
    }

    // Salida
    double exitCol = map.exitX / GameConstants.tileSize;
    double exitRow = map.exitY / GameConstants.tileSize;
    canvas.drawCircle(
      Offset(mmX + exitCol * mmScale, mmY + exitRow * mmScale),
      2,
      Paint()..color = DoomColors.exitColor,
    );

    // Enemigos
    final enemyP = Paint()..color = DoomColors.healthRed;
    for (var enemy in map.enemies) {
      if (!enemy.isActive) continue;
      double ex = enemy.x / GameConstants.tileSize * mmScale;
      double ey = enemy.y / GameConstants.tileSize * mmScale;
      canvas.drawCircle(
          Offset(mmX + ex, mmY + ey), enemy.isBoss ? 2.5 : 1.5, enemyP);
    }

    // Jugador
    double px = player.x / GameConstants.tileSize * mmScale;
    double py = player.y / GameConstants.tileSize * mmScale;
    canvas.drawCircle(
      Offset(mmX + px, mmY + py),
      2.5,
      Paint()..color = const Color(0xFFE53935),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

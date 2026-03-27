import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../game/game_engine.dart';

/// Efectos visuales: partículas, flash de daño, tile de salida
class EffectsRenderer {

  static void drawParticles(Canvas canvas, List<ParticleEffect> particles) {
    for (var p in particles) {
      if (!p.isActive) continue;
      double opacity = (1.0 - p.progress).clamp(0.0, 1.0);
      double currentSize = p.size * (1.0 - p.progress * 0.5);

      Color color;
      switch (p.type) {
        case ParticleType.impact:
          color = Colors.white.withOpacity(opacity);
          break;
        case ParticleType.death:
          color = Color.lerp(DoomColors.explosion, DoomColors.healthRed, p.progress)!.withOpacity(opacity);
          break;
        case ParticleType.muzzle:
          color = DoomColors.muzzleFlash.withOpacity(opacity);
          break;
        case ParticleType.venom:
          color = DoomColors.venomTentacle.withOpacity(opacity);
          break;
      }

      canvas.drawCircle(Offset(p.x, p.y), currentSize, Paint()..color = color);
      if (currentSize > 3) {
        canvas.drawCircle(Offset(p.x, p.y), currentSize * 1.5,
            Paint()..color = color.withOpacity(opacity * 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      }
    }
  }

  static void drawDamageFlash(Canvas canvas, Size size, double timer) {
    if (timer <= 0) return;
    double opacity = (timer / 0.3).clamp(0.0, 0.5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = DoomColors.damageFlash.withOpacity(opacity));
  }

  static void drawExitTile(Canvas canvas, double x, double y, double time, bool allEnemiesDead) {
    if (!allEnemiesDead) {
      double pulse = 0.5 + 0.5 * sin(time * 2);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: GameConstants.tileSize, height: GameConstants.tileSize),
        Paint()..color = DoomColors.healthRed.withOpacity(0.3 + pulse * 0.3),
      );
      final lp = Paint()..color = DoomColors.healthRed.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawCircle(Offset(x, y - 4), 6, lp);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y + 4), width: 14, height: 10), lp);
    } else {
      double pulse = 0.5 + 0.5 * sin(time * 4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: GameConstants.tileSize + 10, height: GameConstants.tileSize + 10),
        Paint()..color = DoomColors.exitColor.withOpacity(0.2 + pulse * 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: GameConstants.tileSize, height: GameConstants.tileSize),
        Paint()..color = DoomColors.exitColor.withOpacity(0.5 + pulse * 0.3),
      );
      final wp = Paint()..color = Colors.white.withOpacity(0.7 + pulse * 0.2)..style = PaintingStyle.stroke..strokeWidth = 1.5;
      double half = GameConstants.tileSize / 2 - 4;
      canvas.drawLine(Offset(x, y - half), Offset(x, y + half), wp);
      canvas.drawLine(Offset(x - half, y), Offset(x + half, y), wp);
      canvas.drawLine(Offset(x - half * 0.7, y - half * 0.7), Offset(x + half * 0.7, y + half * 0.7), wp);
      canvas.drawLine(Offset(x + half * 0.7, y - half * 0.7), Offset(x - half * 0.7, y + half * 0.7), wp);
      canvas.drawCircle(Offset(x, y), half * 0.3, wp);
      canvas.drawCircle(Offset(x, y), half * 0.65, wp);
    }
  }
}

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Renderizado procedural de todos los sprites del juego
class SpritePainter {
  // ══════════════════════════════════════════════════════════════════════════
  // SPIDER-MAN 2D (Jugador)
  // ══════════════════════════════════════════════════════════════════════════
  static void drawPlayer(Canvas canvas, double x, double y, double angle,
      bool invulnerable, double time, WeaponType currentWeapon) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    if (invulnerable && (time * 10).floor() % 2 == 0) {
      canvas.restore();
      return;
    }

    // Cuerpo azul base
    canvas.drawCircle(
        Offset.zero, 10, Paint()..color = const Color(0xFF1565C0));

    // Mitad frontal roja
    final redPath = Path();
    redPath.addArc(
        Rect.fromCircle(center: Offset.zero, radius: 10), -pi / 2, pi);
    redPath.close();
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFE53935));

    // Telaraña en la parte roja
    final webPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (int i = 0; i < 6; i++) {
      double a = (i * pi / 3) - pi / 2;
      canvas.drawLine(Offset.zero, Offset(cos(a) * 9, sin(a) * 9), webPaint);
    }
    canvas.drawCircle(Offset.zero, 4, webPaint);
    canvas.drawCircle(Offset.zero, 7, webPaint);

    // Lentes blancos
    final eyePaint = Paint()..color = Colors.white;
    canvas.save();
    canvas.rotate(-0.2);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(4.5, -3), width: 5.5, height: 3.5),
        eyePaint);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(4.5, 3), width: 5.5, height: 3.5),
        eyePaint);
    canvas.restore();

    // Brazo con arma visual distinta por tipo
    _drawWeaponArm(canvas, currentWeapon);

    canvas.restore();
  }

  static void _drawWeaponArm(Canvas canvas, WeaponType weapon) {
    switch (weapon) {
      case WeaponType.pistol:
        // Tubo fino blanco
        canvas.drawLine(
            const Offset(8, 0),
            const Offset(17, 0),
            Paint()
              ..color = Colors.white.withOpacity(0.9)
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke);
        canvas.drawCircle(
            const Offset(17, 0), 2, Paint()..color = Colors.white);
        break;

      case WeaponType.shotgun:
        // Cañón ancho azul con bocas abiertas
        canvas.drawRect(Rect.fromLTWH(7, -3, 9, 6),
            Paint()..color = const Color(0xFF1976D2));
        canvas.drawRect(Rect.fromLTWH(15, -4, 3, 8),
            Paint()..color = const Color(0xFF90CAF9));
        final sp = Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(17, -4), const Offset(21, -7), sp);
        canvas.drawLine(const Offset(17, 0), const Offset(21, 0), sp);
        canvas.drawLine(const Offset(17, 4), const Offset(21, 7), sp);
        break;

      case WeaponType.plasmaRifle:
        // Cañón largo cyan con glow
        canvas.drawRect(Rect.fromLTWH(6, -2.5, 15, 5),
            Paint()..color = const Color(0xFF00BCD4));
        canvas.drawRect(
            Rect.fromLTWH(7, -1.2, 13, 2.4), Paint()..color = Colors.white);
        canvas.drawCircle(
            const Offset(21, 0),
            4,
            Paint()
              ..color = const Color(0xFF00BCD4)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
        canvas.drawOval(
            Rect.fromCenter(center: const Offset(13, 0), width: 8, height: 5),
            Paint()
              ..color = const Color(0xFF00BCD4).withOpacity(0.8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
        break;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LADRÓN CON PISTOLA (Imp)
  // ══════════════════════════════════════════════════════════════════════════
  static void drawImp(Canvas canvas, double x, double y, double angle,
      double healthPercent, EnemyState state) {
    canvas.save();
    canvas.translate(x, y);

    if (state == EnemyState.dying) {
      canvas.drawCircle(Offset.zero, 8,
          Paint()..color = DoomColors.thiefBody.withOpacity(0.4));
      canvas.restore();
      return;
    }
    if (state == EnemyState.hurt) {
      canvas.drawCircle(Offset.zero, 12, Paint()..color = Colors.white);
      canvas.restore();
      return;
    }

    canvas.drawCircle(Offset.zero, 11, Paint()..color = DoomColors.thiefBody);
    canvas.drawCircle(Offset.zero, 7, Paint()..color = const Color(0xFF37474F));

    canvas.save();
    canvas.rotate(angle);

    // Gorra
    final capPath = Path()
      ..moveTo(2, -11)
      ..lineTo(5, -17)
      ..lineTo(9, -11)
      ..close();
    canvas.drawPath(capPath, Paint()..color = Colors.black87);

    // Ojos rojos
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(5, -3), width: 5, height: 3),
        Paint()..color = Colors.red.shade700);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(5, 3), width: 5, height: 3),
        Paint()..color = Colors.red.shade700);

    // Pistola pequeña
    canvas.drawRect(
        Rect.fromLTWH(7, -1.5, 8, 3), Paint()..color = Colors.grey.shade600);

    canvas.restore();
    if (healthPercent < 1.0) _drawHealthBar(canvas, healthPercent, 11, false);
    canvas.restore();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LADRÓN CON ESCOPETA (Demon)
  // ══════════════════════════════════════════════════════════════════════════
  static void drawDemon(Canvas canvas, double x, double y, double angle,
      double healthPercent, EnemyState state) {
    canvas.save();
    canvas.translate(x, y);

    if (state == EnemyState.dying) {
      canvas.drawCircle(Offset.zero, 10,
          Paint()..color = DoomColors.thiefBody.withOpacity(0.4));
      canvas.restore();
      return;
    }
    if (state == EnemyState.hurt) {
      canvas.drawCircle(Offset.zero, 14, Paint()..color = Colors.white);
      canvas.restore();
      return;
    }

    canvas.drawCircle(
        Offset.zero, 13, Paint()..color = const Color(0xFF5D4037));
    canvas.drawCircle(Offset.zero, 9, Paint()..color = const Color(0xFF4E342E));

    canvas.save();
    canvas.rotate(angle);

    // Sombrero más grande
    canvas.drawRect(
        Rect.fromLTWH(2, -16, 8, 4), Paint()..color = Colors.black87);
    canvas.drawRect(
        Rect.fromLTWH(-1, -13, 14, 3), Paint()..color = Colors.black87);

    // Ojos naranjas
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(6, -4), width: 5.5, height: 3.5),
        Paint()..color = Colors.orange.shade700);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(6, 4), width: 5.5, height: 3.5),
        Paint()..color = Colors.orange.shade700);

    // Escopeta ancha
    canvas.drawRect(
        Rect.fromLTWH(7, -2.5, 11, 5), Paint()..color = Colors.grey.shade500);
    canvas.drawRect(
        Rect.fromLTWH(17, -3.5, 3, 7), Paint()..color = Colors.grey.shade300);

    canvas.restore();
    if (healthPercent < 1.0) _drawHealthBar(canvas, healthPercent, 13, false);
    canvas.restore();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RHINO — Jefe N1
  // ══════════════════════════════════════════════════════════════════════════
  static void drawRhino(Canvas canvas, double x, double y, double angle,
      double healthPercent, EnemyState state, double time) {
    canvas.save();
    canvas.translate(x, y);

    if (state == EnemyState.dying) {
      canvas.drawCircle(Offset.zero, 18,
          Paint()..color = DoomColors.rhinoBody.withOpacity(0.4));
      canvas.restore();
      return;
    }
    if (state == EnemyState.hurt) {
      canvas.drawCircle(Offset.zero, 26, Paint()..color = Colors.white);
      canvas.restore();
      return;
    }

    double pulse = 1.0 + sin(time * 3) * 0.04;

    canvas.drawCircle(
        Offset.zero, 22 * pulse, Paint()..color = DoomColors.rhinoBody);
    canvas.drawCircle(
        Offset.zero, 15 * pulse, Paint()..color = const Color(0xFF607D8B));

    // Placas de armadura
    final armorPaint = Paint()
      ..color = DoomColors.rhinoArmor.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (int i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 10.0 + i * 4.0),
        -1.0,
        2.0,
        false,
        armorPaint,
      );
    }

    canvas.save();
    canvas.rotate(angle);

    // Cuerno principal
    final hornPath = Path()
      ..moveTo(14, -3)
      ..lineTo(28, 0)
      ..lineTo(14, 3)
      ..close();
    canvas.drawPath(hornPath, Paint()..color = DoomColors.rhinoArmor);

    canvas.restore();

    _drawHealthBar(canvas, healthPercent, 22, true);
    _drawBossLabel(canvas, '⚠ RHINO ⚠', 22);
    canvas.restore();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUITRE — Jefe N2
  // ══════════════════════════════════════════════════════════════════════════
  static void drawCacodemon(Canvas canvas, double x, double y, double angle,
      double healthPercent, EnemyState state, double time) {
    _drawVultureInternal(
        canvas, x, y, angle, healthPercent, state, time, false);
  }

  static void drawVultureBoss(Canvas canvas, double x, double y, double angle,
      double healthPercent, EnemyState state, double time) {
    _drawVultureInternal(canvas, x, y, angle, healthPercent, state, time, true);
  }

  static void _drawVultureInternal(
      Canvas canvas,
      double x,
      double y,
      double angle,
      double healthPercent,
      EnemyState state,
      double time,
      bool isBoss) {
    canvas.save();
    canvas.translate(x, y);

    double bobY = sin(time * (isBoss ? 4.0 : 3.0)) * (isBoss ? 5 : 3);
    canvas.translate(0, bobY);

    double r = isBoss ? 20.0 : 12.0;

    if (state == EnemyState.dying) {
      canvas.drawCircle(Offset.zero, r,
          Paint()..color = DoomColors.vultureBody.withOpacity(0.4));
      canvas.restore();
      return;
    }
    if (state == EnemyState.hurt) {
      canvas.drawCircle(Offset.zero, r + 4, Paint()..color = Colors.white);
      canvas.restore();
      return;
    }

    // Glow verde
    canvas.drawCircle(
        Offset.zero,
        r + 8,
        Paint()
          ..color = DoomColors.vultureBody.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(Offset.zero, r, Paint()..color = DoomColors.vultureBody);
    canvas.drawCircle(
        Offset.zero, r * 0.65, Paint()..color = const Color(0xFF3E5723));

    canvas.save();
    canvas.rotate(angle);

    double ws = isBoss ? 1.7 : 1.0;
    // Alas
    final wingPaint = Paint()..color = DoomColors.vultureWing;
    final wingT = Path()
      ..moveTo(0, -r)
      ..lineTo(-16 * ws, -28 * ws)
      ..lineTo(10 * ws, -r * 0.6)
      ..close();
    final wingB = Path()
      ..moveTo(0, r)
      ..lineTo(-16 * ws, 28 * ws)
      ..lineTo(10 * ws, r * 0.6)
      ..close();
    canvas.drawPath(wingT, wingPaint);
    canvas.drawPath(wingB, wingPaint);

    // Pico
    final beakPath = Path()
      ..moveTo(r, -3)
      ..lineTo(r + 10, 0)
      ..lineTo(r, 3)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = DoomColors.vultureEye);

    // Ojo
    canvas.drawCircle(
        Offset(r * 0.5, 0), isBoss ? 7 : 5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(r * 0.65, 0), isBoss ? 4 : 3,
        Paint()..color = DoomColors.vultureEye);
    canvas.drawCircle(
        Offset(r * 0.72, 0), isBoss ? 2 : 1.5, Paint()..color = Colors.black);

    canvas.restore();

    _drawHealthBar(canvas, healthPercent, r, isBoss);
    if (isBoss) _drawBossLabel(canvas, '⚠ BUITRE ⚠', r);
    canvas.restore();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VENOM — Jefe N3
  // ══════════════════════════════════════════════════════════════════════════
  static void drawVenom(Canvas canvas, double x, double y, double angle,
      double healthPercent, EnemyState state, double time) {
    canvas.save();
    canvas.translate(x, y);

    if (state == EnemyState.dying) {
      canvas.drawCircle(Offset.zero, 20,
          Paint()..color = DoomColors.venomBody.withOpacity(0.4));
      canvas.restore();
      return;
    }
    if (state == EnemyState.hurt) {
      canvas.drawCircle(Offset.zero, 28,
          Paint()..color = DoomColors.venomTentacle.withOpacity(0.7));
      canvas.restore();
      return;
    }

    double pulse = 1.0 + sin(time * 5) * 0.05;

    // Tentáculos animados
    final tentaclePaint = Paint()
      ..color = DoomColors.venomTentacle.withOpacity(0.65)
      ..strokeWidth = 4.5 * pulse
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      double a = (i * pi / 3) + time * 2;
      double len = 28 + sin(time * 3 + i) * 6;
      canvas.drawLine(
        Offset(cos(a) * 20, sin(a) * 20),
        Offset(cos(a) * len, sin(a) * len),
        tentaclePaint,
      );
    }

    // Aura violeta
    canvas.drawCircle(
        Offset.zero,
        28 * pulse,
        Paint()
          ..color = DoomColors.venomTentacle.withOpacity(0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Cuerpo negro
    canvas.drawCircle(
        Offset.zero, 24 * pulse, Paint()..color = DoomColors.venomBody);

    canvas.save();
    canvas.rotate(angle);

    // Símbolo araña blanco
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(6, 0), width: 12, height: 18),
        Paint()..color = DoomColors.venomSymbol.withOpacity(0.9));
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(6, 0), width: 14, height: 7),
        Paint()..color = DoomColors.venomSymbol.withOpacity(0.9));

    // Ojos blancos grandes
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(14, -8), width: 12, height: 7),
        Paint()..color = Colors.white);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(14, 8), width: 12, height: 7),
        Paint()..color = Colors.white);
    // Pupilas violeta
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(17, -8), width: 6, height: 5),
        Paint()..color = DoomColors.venomTentacle);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(17, 8), width: 6, height: 5),
        Paint()..color = DoomColors.venomTentacle);

    // Dientes
    final toothPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 5; i++) {
      double tx = 12.0 + i * 2.6;
      final tooth = Path()
        ..moveTo(tx, -2)
        ..lineTo(tx + 1.3, 2)
        ..lineTo(tx + 2.6, -2)
        ..close();
      canvas.drawPath(tooth, toothPaint);
    }

    canvas.restore();

    _drawHealthBar(canvas, healthPercent, 24, true);
    _drawBossLabel(canvas, '⚠ VENOM ⚠', 24);
    canvas.restore();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BARRA DE VIDA Y ETIQUETA JEFE
  // ══════════════════════════════════════════════════════════════════════════
  static void _drawHealthBar(
      Canvas canvas, double percent, double entityRadius, bool isBoss) {
    double bw = isBoss ? entityRadius * 3 : entityRadius * 2;
    double bh = isBoss ? 5 : 3;
    double by = -(entityRadius + (isBoss ? 16 : 9));

    canvas.drawRect(Rect.fromLTWH(-bw / 2, by, bw, bh),
        Paint()..color = Colors.black.withOpacity(0.7));

    Color c = percent > 0.6
        ? DoomColors.healthGreen
        : percent > 0.3
            ? DoomColors.healthYellow
            : DoomColors.healthRed;

    canvas.drawRect(
        Rect.fromLTWH(-bw / 2, by, bw * percent, bh), Paint()..color = c);

    if (isBoss) {
      canvas.drawRect(
          Rect.fromLTWH(-bw / 2, by, bw, bh),
          Paint()
            ..color = c.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }
  }

  static void _drawBossLabel(Canvas canvas, String label, double entityRadius) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -(entityRadius + 27)));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROYECTILES
  // ══════════════════════════════════════════════════════════════════════════
  static void drawProjectile(Canvas canvas, double x, double y,
      bool isPlayerBullet, WeaponType weaponType,
      {bool isVenom = false}) {
    Color color;
    double size;

    if (isVenom) {
      color = DoomColors.venomTentacle;
      size = 6;
    } else if (!isPlayerBullet) {
      color = DoomColors.bulletEnemy;
      size = 5;
    } else {
      switch (weaponType) {
        case WeaponType.pistol:
          color = Colors.white;
          size = 4;
          break;
        case WeaponType.shotgun:
          color = const Color(0xFF90CAF9);
          size = 3;
          break;
        case WeaponType.plasmaRifle:
          color = const Color(0xFF00BCD4);
          size = 9; // visualmente mucho más grande
          break;
      }
    }

    // Glow
    canvas.drawCircle(
        Offset(x, y),
        size + 4,
        Paint()
          ..color = color.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    // Núcleo
    canvas.drawCircle(Offset(x, y), size, Paint()..color = color);
    // Centro blanco
    canvas.drawCircle(Offset(x, y), size * 0.3, Paint()..color = Colors.white);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PICKUPS
  // ══════════════════════════════════════════════════════════════════════════
  static void drawPickup(
      Canvas canvas, double x, double y, PickupType type, double bobOffset) {
    double drawY = y + sin(bobOffset) * 3;
    Color color;
    String label;

    switch (type) {
      case PickupType.health:
        color = DoomColors.healthPickup;
        label = '+';
        break;
      case PickupType.ammo:
        color = DoomColors.ammoPickup;
        label = 'W';
        break;
      case PickupType.shotgunPickup:
        color = const Color(0xFF29B6F6);
        label = 'ER';
        break;
      case PickupType.plasmaRiflePickup:
        color = const Color(0xFF00BCD4);
        label = 'RI';
        break;
    }

    canvas.drawCircle(
        Offset(x, drawY),
        15,
        Paint()
          ..color = color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(
        Offset(x, drawY),
        10,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(
        Offset(x, drawY), 10, Paint()..color = color.withOpacity(0.2));

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: label.length > 1 ? 8.5 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, drawY - tp.height / 2));
  }
}

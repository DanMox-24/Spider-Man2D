import 'enemy.dart';

// ─── ENEMIGOS COMUNES ────────────────────────────────────────────────────────

/// Ladrón con pistola — rápido, poca vida, dispara individual
class Imp extends Enemy {
  Imp({required double x, required double y})
      : super(
          x: x, y: y,
          health: 35,
          speed: 85.0,
          contactDamage: 6,
          projectileDamage: 10,
          attackCooldown: 1.3,
          radius: 11.0,
          canShoot: true,
          scoreValue: 100,
          typeName: 'Ladrón',
          projectilesPerShot: 1,
        );
}

/// Ladrón con escopeta — más lento, más vida, dispara spread
class Demon extends Enemy {
  Demon({required double x, required double y})
      : super(
          x: x, y: y,
          health: 55,
          speed: 60.0,
          contactDamage: 10,
          projectileDamage: 8,
          attackCooldown: 1.8,
          radius: 13.0,
          canShoot: true,
          scoreValue: 150,
          typeName: 'Escopetero',
          projectilesPerShot: 3, // dispara 3 perdigones
        );
}

/// Cacodemon — sin uso, redirigido a Vulture por compatibilidad
class Cacodemon extends Enemy {
  Cacodemon({required double x, required double y})
      : super(
          x: x, y: y,
          health: 50,
          speed: 70.0,
          contactDamage: 8,
          projectileDamage: 10,
          attackCooldown: 1.5,
          radius: 12.0,
          canShoot: true,
          scoreValue: 120,
          typeName: 'Ladrón+',
        );
}

// ─── JEFES ───────────────────────────────────────────────────────────────────

/// Rhino — jefe nivel 1: tanque melee, muy lento, enorme vida
class RhinoBoss extends Enemy {
  RhinoBoss({required double x, required double y})
      : super(
          x: x, y: y,
          health: 350,
          speed: 42.0,
          contactDamage: 35,
          projectileDamage: 0,
          attackCooldown: 0.7,
          radius: 22.0,
          canShoot: false,
          scoreValue: 800,
          typeName: 'RHINO',
          isBoss: true,
        );
}

/// Buitre — jefe nivel 2: vuela, dispara ráfaga en abanico (alas)
class VultureBoss extends Enemy {
  VultureBoss({required double x, required double y})
      : super(
          x: x, y: y,
          health: 280,
          speed: 80.0,
          contactDamage: 15,
          projectileDamage: 12,
          attackCooldown: 1.4,
          radius: 20.0,
          canShoot: true,
          scoreValue: 1000,
          typeName: 'BUITRE',
          isBoss: true,
          projectilesPerShot: 5, // 5 plumas/perdigones en abanico
        );
}

/// Venom — jefe nivel 3: ataque combinado (disparo simbionte + melee)
class VenomBoss extends Enemy {
  double _tentacleTimer = 0;

  VenomBoss({required double x, required double y})
      : super(
          x: x, y: y,
          health: 500,
          speed: 65.0,
          contactDamage: 40,
          projectileDamage: 18,
          attackCooldown: 1.0,
          radius: 24.0,
          canShoot: true,
          scoreValue: 1500,
          typeName: 'VENOM',
          isBoss: true,
          projectilesPerShot: 4,
        );

  /// Venom alterna entre melee charge y disparo simbionte
  bool get shouldMeleeCharge => _tentacleTimer > 2.0;

  @override
  void update(double dt, double playerX, double playerY) {
    _tentacleTimer += dt;
    if (_tentacleTimer > 4.0) _tentacleTimer = 0;
    super.update(dt, playerX, playerY);
  }
}

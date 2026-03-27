import 'dart:math';
import '../utils/constants.dart';

/// Clase base para todos los enemigos
class Enemy {
  double x, y, angle;
  int health, maxHealth;
  double speed;
  int contactDamage, projectileDamage;
  double attackCooldown, _attackTimer;
  double radius;
  EnemyState state;
  double stateTimer, deathTimer;
  bool canShoot;
  int scoreValue;
  String typeName;
  bool isBoss;

  // Para ataques tipo spread del jefe
  int projectilesPerShot;

  Enemy({
    required this.x,
    required this.y,
    required this.health,
    required this.speed,
    required this.contactDamage,
    this.projectileDamage = 0,
    this.attackCooldown = 1.0,
    this.radius = 12.0,
    this.canShoot = false,
    this.scoreValue = 100,
    this.typeName = 'Enemigo',
    this.angle = 0,
    this.isBoss = false,
    this.projectilesPerShot = 1,
  })  : maxHealth = health,
        _attackTimer = 0,
        state = EnemyState.idle,
        stateTimer = 0,
        deathTimer = 0;

  bool get isDead => state == EnemyState.dead;
  bool get isDying => state == EnemyState.dying;
  bool get isActive => state != EnemyState.dead;
  bool get canAttack => _attackTimer <= 0;
  double get healthPercent => health / maxHealth;

  void update(double dt, double playerX, double playerY) {
    if (isDead) return;
    _attackTimer -= dt;
    if (_attackTimer < 0) _attackTimer = 0;

    if (isDying) {
      deathTimer -= dt;
      if (deathTimer <= 0) state = EnemyState.dead;
      return;
    }

    if (state == EnemyState.hurt) {
      stateTimer -= dt;
      if (stateTimer <= 0) state = EnemyState.chasing;
      return;
    }

    double dx = playerX - x;
    double dy = playerY - y;
    double distance = sqrt(dx * dx + dy * dy);
    angle = atan2(dy, dx);

    double meleeStopDist = radius + GameConstants.playerRadius + 2;

    if (!canShoot && distance <= meleeStopDist + 2) {
      state = EnemyState.attacking;
      if (distance > meleeStopDist - 4 && distance > 0) {
        x += (dx / distance) * speed * 0.3 * dt;
        y += (dy / distance) * speed * 0.3 * dt;
      }
    } else if (canShoot &&
        distance <= GameConstants.enemyAttackRange + radius) {
      // Rango de disparo
      state = EnemyState.attacking;
    } else if (distance <= GameConstants.enemyDetectionRange) {
      state = EnemyState.chasing;
      if (distance > 0) {
        x += (dx / distance) * speed * dt;
        y += (dy / distance) * speed * dt;
      }
    } else {
      state = EnemyState.idle;
      stateTimer -= dt;
      if (stateTimer <= 0) {
        stateTimer = 1.5 + Random().nextDouble() * 2.5;
        angle = Random().nextDouble() * 2 * pi;
      }
      x += cos(angle) * speed * 0.25 * dt;
      y += sin(angle) * speed * 0.25 * dt;
    }
  }

  void takeDamage(int amount) {
    if (isDead || isDying) return;
    health -= amount;
    if (health <= 0) {
      health = 0;
      state = EnemyState.dying;
      deathTimer = isBoss ? 1.0 : 0.5;
    } else {
      state = EnemyState.hurt;
      stateTimer = 0.15;
    }
  }

  void resetAttackTimer() => _attackTimer = attackCooldown;

  bool shouldShoot(double playerX, double playerY) {
    if (!canShoot || !canAttack || isDead || isDying) return false;
    double dx = playerX - x;
    double dy = playerY - y;
    double dist = sqrt(dx * dx + dy * dy);
    return dist <= GameConstants.enemyDetectionRange * 0.85;
  }
}

import 'dart:math';
import '../utils/constants.dart';
import '../utils/audio_manager.dart';
import 'player.dart';
import 'enemy.dart';
import 'enemy_types.dart';
import 'projectile.dart';
import 'pickup.dart';
import 'weapon.dart';
import 'game_map.dart';
import 'levels.dart';
import 'collision.dart';

/// Motor principal del juego — gestiona el game loop y el estado
class GameEngine {
  GameState state = GameState.menu;
  late Player player;
  late GameMap currentMap;
  late CollisionSystem collision;
  late WeaponManager weaponManager;
  List<Projectile> projectiles = [];
  int currentLevel = 0;
  int killCount = 0;
  int totalKills = 0;
  List<ParticleEffect> particles = [];

  final AudioManager audio = AudioManager();
  final _rnd = Random();

  GameEngine() {
    player = Player(x: 0, y: 0);
    weaponManager = WeaponManager();
    _loadLevel(0);
  }

  void _loadLevel(int level) {
    currentLevel = level;
    currentMap = Levels.getLevel(level);
    collision = CollisionSystem(currentMap);
    projectiles.clear();
    particles.clear();
    killCount = 0;
    player.x = currentMap.playerSpawnX;
    player.y = currentMap.playerSpawnY;
    weaponManager = WeaponManager();
  }

  void startNewGame() {
    currentLevel = 0;
    totalKills = 0;
    player.fullReset(0, 0);
    _loadLevel(0);
    state = GameState.playing;
    audio.playGameMusic();
  }

  void nextLevel() {
    if (currentLevel + 1 >= GameConstants.totalLevels) {
      state = GameState.victory;
      audio.playLevelComplete();
      weaponManager.switchTo(player.currentWeapon);
      return;
    }
    totalKills += killCount;
    int savedScore = player.score;
    int savedHealth = player.health;
    _loadLevel(currentLevel + 1);
    player.score = savedScore;
    player.health = savedHealth;
    state = GameState.playing;
  }

  void update(double dt) {
    if (state != GameState.playing) return;

    // Jugador
    player.update(dt);
    collision.resolvePlayerWallCollision(player);

    // Armas
    weaponManager.switchTo(player.currentWeapon);
    weaponManager.update(dt);

    if (player.isShooting && player.hasAmmo()) {
      List<Projectile> newBullets =
          weaponManager.tryFire(player.x, player.y, player.angle);
      if (newBullets.isNotEmpty) {
        projectiles.addAll(newBullets);
        player.consumeAmmo(weaponManager.current.ammoPerShot);
      }
    }

    // Enemigos
    for (var enemy in currentMap.enemies) {
      if (!enemy.isActive) continue;
      enemy.update(dt, player.x, player.y);
      collision.resolveEnemyWallCollision(enemy);

      // Disparos de enemigos
      if (enemy.shouldShoot(player.x, player.y)) {
        enemy.resetAttackTimer();
        _spawnEnemyProjectiles(enemy);
      }
    }

    // Proyectiles
    for (var proj in projectiles) {
      proj.update(dt);
      if (!proj.isActive) continue;

      if (collision.projectileHitsWall(proj)) {
        proj.isActive = false;
        _spawnImpactParticles(proj.x, proj.y, proj.isVenom);
        continue;
      }

      if (proj.isPlayerBullet) {
        Enemy? hit = collision.projectileHitsEnemy(proj, currentMap.enemies);
        if (hit != null) {
          proj.isActive = false;
          hit.takeDamage(proj.damage);
          audio.playEnemyHit();
          _spawnImpactParticles(proj.x, proj.y, false);
          if (hit.isDying) {
            player.score += hit.scoreValue;
            killCount++;
            audio.playEnemyDeath();
            _spawnDeathParticles(hit.x, hit.y, hit.isBoss);
          }
        }
      } else {
        if (collision.projectileHitsPlayer(proj, player)) {
          proj.isActive = false;
          player.takeDamage(proj.damage);
          audio.playPlayerHurt();
        }
      }
    }

    // Daño por contacto
    Enemy? touchedEnemy =
        collision.playerTouchesEnemy(player, currentMap.enemies);
    if (touchedEnemy != null && touchedEnemy.canAttack) {
      player.takeDamage(touchedEnemy.contactDamage);
      touchedEnemy.resetAttackTimer();
      audio.playPlayerHurt();
    }

    // Pickups
    Pickup? pickup = collision.playerTouchesPickup(player, currentMap.pickups);
    if (pickup != null) _handlePickup(pickup);

    // Puertas automáticas
    _checkDoors();

    // Salida del nivel
    if (collision.playerOnExit(player)) {
      bool allDead = currentMap.enemies.every((e) => e.isDead);
      if (allDead) {
        audio.playLevelComplete();
        state = GameState.levelComplete;
      }
    }

    // Muerte del jugador
    if (player.isDead) {
      state = GameState.gameOver;
      audio.playGameOver();
    }

    // Partículas
    for (var p in particles) p.update(dt);

    // Limpieza
    projectiles.removeWhere((p) => !p.isActive);
    currentMap.enemies.removeWhere((e) => e.isDead);
    currentMap.pickups.removeWhere((p) => !p.isActive);
    particles.removeWhere((p) => !p.isActive);
  }

  /// Genera proyectiles según el tipo de enemigo
  void _spawnEnemyProjectiles(Enemy enemy) {
    if (enemy is RhinoBoss) return; // Rhino solo melee

    if (enemy is VultureBoss) {
      // Abanico de 5 plumas
      projectiles.addAll(
          Projectile.vultureFanShot(enemy.x, enemy.y, player.x, player.y));
      return;
    }

    if (enemy is VenomBoss) {
      // Látigo simbionte: 4 proyectiles
      projectiles.addAll(
          Projectile.venomTentacleShot(enemy.x, enemy.y, player.x, player.y));
      return;
    }

    if (enemy is Demon) {
      // Ladrón escopeta: spread de 3
      projectiles.addAll(
          Projectile.enemyShotgunBlast(enemy.x, enemy.y, player.x, player.y));
      return;
    }

    // Ladrón pistola: bala única
    projectiles
        .add(Projectile.enemyBullet(enemy.x, enemy.y, player.x, player.y));
  }

  void _handlePickup(Pickup pickup) {
    switch (pickup.type) {
      case PickupType.health:
        if (player.health < player.maxHealth) {
          player.heal(30);
          pickup.collect();
          audio.playPickup();
        }
        break;
      case PickupType.ammo:
        player.addAmmoForWeapon(player.currentWeapon, 20);
        pickup.collect();
        audio.playPickup();
        break;
      case PickupType.shotgunPickup:
        player.pickupWeapon(WeaponType.shotgun);
        pickup.collect();
        audio.playPickup();
        break;
      case PickupType.plasmaRiflePickup:
        player.pickupWeapon(WeaponType.plasmaRifle);
        pickup.collect();
        audio.playPickup();
        break;
    }
  }

  void _checkDoors() {
    double r = player.radius + 5;
    int minC = ((player.x - r) / GameConstants.tileSize).floor() - 1;
    int maxC = ((player.x + r) / GameConstants.tileSize).floor() + 1;
    int minR = ((player.y - r) / GameConstants.tileSize).floor() - 1;
    int maxR = ((player.y + r) / GameConstants.tileSize).floor() + 1;

    for (int row = minR; row <= maxR; row++) {
      for (int col = minC; col <= maxC; col++) {
        if (currentMap.isDoor(col, row) &&
            collision.playerNearDoor(player, col, row)) {
          currentMap.openDoor(col, row);
          audio.playDoorOpen();
        }
      }
    }
  }

  void _spawnImpactParticles(double x, double y, bool isVenom) {
    for (int i = 0; i < 5; i++) {
      particles.add(ParticleEffect(
        x: x,
        y: y,
        dx: (_rnd.nextDouble() - 0.5) * 110,
        dy: (_rnd.nextDouble() - 0.5) * 110,
        lifetime: 0.25 + _rnd.nextDouble() * 0.2,
        size: 2 + _rnd.nextDouble() * 3,
        type: isVenom ? ParticleType.venom : ParticleType.impact,
      ));
    }
  }

  void _spawnDeathParticles(double x, double y, bool isBoss) {
    int count = isBoss ? 20 : 12;
    double spread = isBoss ? 200 : 160;
    for (int i = 0; i < count; i++) {
      particles.add(ParticleEffect(
        x: x,
        y: y,
        dx: (_rnd.nextDouble() - 0.5) * spread,
        dy: (_rnd.nextDouble() - 0.5) * spread,
        lifetime: 0.5 + _rnd.nextDouble() * 0.6,
        size:
            isBoss ? (5 + _rnd.nextDouble() * 8) : (3 + _rnd.nextDouble() * 5),
        type: ParticleType.death,
      ));
    }
  }

  int get enemiesRemaining =>
      currentMap.enemies.where((e) => e.isActive).length;
}

enum ParticleType { impact, death, muzzle, venom }

class ParticleEffect {
  double x, y, dx, dy, lifetime, maxLifetime, size;
  bool isActive;
  ParticleType type;

  ParticleEffect({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.lifetime,
    this.size = 3,
    this.type = ParticleType.impact,
  })  : maxLifetime = lifetime,
        isActive = true;

  double get progress => 1.0 - (lifetime / maxLifetime);

  void update(double dt) {
    if (!isActive) return;
    x += dx * dt;
    y += dy * dt;
    dx *= 0.94;
    dy *= 0.94;
    lifetime -= dt;
    if (lifetime <= 0) isActive = false;
  }
}

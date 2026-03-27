import 'dart:math';
import '../utils/constants.dart';

class Player {
  double x;
  double y;
  double angle;
  int health;
  int maxHealth;
  int score;
  int keys;
  bool isInvulnerable;
  double invulnerabilityTimer;
  double damageFlashTimer;

  double moveX = 0;
  double moveY = 0;
  double aimAngle = 0;
  bool isShooting = false;

  WeaponType currentWeapon;
  Map<WeaponType, int> ammo;
  Map<WeaponType, bool> weaponsOwned;

  Player({
    required this.x,
    required this.y,
    this.angle = 0,
    this.health = GameConstants.playerMaxHealth,
    this.maxHealth = GameConstants.playerMaxHealth,
    this.score = 0,
    this.keys = 0,
    this.isInvulnerable = false,
    this.invulnerabilityTimer = 0,
    this.damageFlashTimer = 0,
    this.currentWeapon = WeaponType.pistol,
  })  : ammo = {
          WeaponType.pistol: 999,
          WeaponType.shotgun: 0,
          WeaponType.plasmaRifle: 0,
        },
        weaponsOwned = {
          WeaponType.pistol: true,
          WeaponType.shotgun: false,
          WeaponType.plasmaRifle: false,
        };

  double get radius => GameConstants.playerRadius;
  bool get isDead => health <= 0;
  bool get isShowingDamageFlash => damageFlashTimer > 0;

  void update(double dt) {
    if (moveX != 0 || moveY != 0) {
      double speed = GameConstants.playerSpeed;
      x += moveX * speed * dt;
      y += moveY * speed * dt;
      angle = atan2(moveY, moveX);
    }

    if (isInvulnerable) {
      invulnerabilityTimer -= dt;
      if (invulnerabilityTimer <= 0) {
        isInvulnerable = false;
        invulnerabilityTimer = 0;
      }
    }

    if (damageFlashTimer > 0) {
      damageFlashTimer -= dt;
      if (damageFlashTimer < 0) damageFlashTimer = 0;
    }
  }

  void takeDamage(int amount) {
    if (isInvulnerable || isDead) return;
    health -= amount;
    if (health < 0) health = 0;
    isInvulnerable = true;
    invulnerabilityTimer = GameConstants.playerInvulnerabilityTime;
    damageFlashTimer = 0.3;
  }

  void heal(int amount) {
    health += amount;
    if (health > maxHealth) health = maxHealth;
  }

  void addAmmo(int amount) {
    ammo[currentWeapon] = (ammo[currentWeapon] ?? 0) + amount;
  }

  void addAmmoForWeapon(WeaponType weapon, int amount) {
    ammo[weapon] = (ammo[weapon] ?? 0) + amount;
  }

  void pickupWeapon(WeaponType weapon) {
    weaponsOwned[weapon] = true;
    switch (weapon) {
      case WeaponType.shotgun:
        addAmmoForWeapon(WeaponType.shotgun, 10);
        break;
      case WeaponType.plasmaRifle:
        addAmmoForWeapon(WeaponType.plasmaRifle, 40);
        break;
      default:
        break;
    }
    currentWeapon = weapon;
  }

  void switchWeapon() {
    List<WeaponType> owned =
        WeaponType.values.where((w) => weaponsOwned[w] == true).toList();
    if (owned.length <= 1) return;
    int idx = owned.indexOf(currentWeapon);
    currentWeapon = owned[(idx + 1) % owned.length];
  }

  bool hasAmmo() {
    if (currentWeapon == WeaponType.pistol) return true;
    return (ammo[currentWeapon] ?? 0) > 0;
  }

  void consumeAmmo(int amount) {
    if (currentWeapon == WeaponType.pistol) return;
    ammo[currentWeapon] = ((ammo[currentWeapon] ?? 0) - amount).clamp(0, 9999);
  }

  void addKey() => keys++;
  bool useKey() {
    if (keys > 0) {
      keys--;
      return true;
    }
    return false;
  }

  void reset(double spawnX, double spawnY) {
    x = spawnX;
    y = spawnY;
    angle = 0;
    health = maxHealth;
    isInvulnerable = false;
    invulnerabilityTimer = 0;
    damageFlashTimer = 0;
    moveX = 0;
    moveY = 0;
    isShooting = false;
    keys = 0;
    currentWeapon = WeaponType.pistol;
    ammo = {
      WeaponType.pistol: 999,
      WeaponType.shotgun: 0,
      WeaponType.plasmaRifle: 0
    };
    weaponsOwned = {
      WeaponType.pistol: true,
      WeaponType.shotgun: false,
      WeaponType.plasmaRifle: false
    };
  }

  void fullReset(double spawnX, double spawnY) {
    reset(spawnX, spawnY);
    score = 0;
  }
}

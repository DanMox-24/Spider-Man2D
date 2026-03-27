import 'dart:math';
import '../utils/constants.dart';

/// Representa un proyectil en el juego
class Projectile {
  double x, y, dx, dy, speed, radius, lifetime;
  int damage;
  bool isPlayerBullet, isActive;
  WeaponType weaponType;
  bool isVenom;

  Projectile({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.speed,
    required this.damage,
    required this.isPlayerBullet,
    this.weaponType = WeaponType.pistol,
    this.radius = GameConstants.bulletRadius,
    this.isActive = true,
    this.lifetime = 3.0,
    this.isVenom = false,
  });

  void update(double dt) {
    if (!isActive) return;
    x += dx * speed * dt;
    y += dy * speed * dt;
    lifetime -= dt;
    if (lifetime <= 0) isActive = false;
  }

  // ── ARMAS DEL JUGADOR ────────────────────────────────────────────────────

  /// Lanzarredes básico — disparo único, cadencia media
  static Projectile playerPistol(double fromX, double fromY, double angle) {
    return Projectile(
      x: fromX,
      y: fromY,
      dx: cos(angle),
      dy: sin(angle),
      speed: GameConstants.bulletSpeed,
      damage: 20,
      isPlayerBullet: true,
      weaponType: WeaponType.pistol,
      radius: 4.0,
    );
  }

  /// Explosión de redes — 5 proyectiles en cono, daño bajo individual
  static List<Projectile> playerShotgun(
      double fromX, double fromY, double angle) {
    List<Projectile> pellets = [];
    final rnd = Random();
    for (int i = 0; i < 5; i++) {
      double spread = (rnd.nextDouble() - 0.5) * 0.60;
      pellets.add(Projectile(
        x: fromX,
        y: fromY,
        dx: cos(angle + spread),
        dy: sin(angle + spread),
        speed: GameConstants.bulletSpeed * 1.05,
        damage: 9,
        isPlayerBullet: true,
        weaponType: WeaponType.shotgun,
        radius: 3.5,
        lifetime: 1.2,
      ));
    }
    return pellets;
  }

  /// Red de impacto — proyectil ÚNICO muy rápido, daño ALTO, tamaño grande
  static Projectile playerPlasma(double fromX, double fromY, double angle) {
    return Projectile(
      x: fromX, y: fromY,
      dx: cos(angle), dy: sin(angle),
      speed: GameConstants.bulletSpeed * 1.6, // mucho más rápida
      damage: 40, // el doble de daño
      isPlayerBullet: true,
      weaponType: WeaponType.plasmaRifle,
      radius: 8.0, // radio doble → visual grande
      lifetime: 2.5,
    );
  }

  // ── PROYECTILES ENEMIGOS ─────────────────────────────────────────────────

  /// Bala de pistola de ladrón — simple
  static Projectile enemyBullet(
      double fromX, double fromY, double toX, double toY) {
    double angle = atan2(toY - fromY, toX - fromX);
    return Projectile(
      x: fromX,
      y: fromY,
      dx: cos(angle),
      dy: sin(angle),
      speed: GameConstants.bulletSpeed * 0.55,
      damage: 10,
      isPlayerBullet: false,
      radius: 4.0,
    );
  }

  /// Perdigón de escopeta enemiga — spread de 3, daño bajo
  static List<Projectile> enemyShotgunBlast(
      double fromX, double fromY, double toX, double toY) {
    double baseAngle = atan2(toY - fromY, toX - fromX);
    List<Projectile> pellets = [];
    List<double> offsets = [-0.3, 0.0, 0.3];
    for (double off in offsets) {
      pellets.add(Projectile(
        x: fromX,
        y: fromY,
        dx: cos(baseAngle + off),
        dy: sin(baseAngle + off),
        speed: GameConstants.bulletSpeed * 0.5,
        damage: 7,
        isPlayerBullet: false,
        radius: 3.5,
        lifetime: 1.0,
      ));
    }
    return pellets;
  }

  /// Abanico del Buitre — 5 plumas en cono amplio
  static List<Projectile> vultureFanShot(
      double fromX, double fromY, double toX, double toY) {
    double baseAngle = atan2(toY - fromY, toX - fromX);
    List<Projectile> shots = [];
    int count = 5;
    double spread = 0.5;
    for (int i = 0; i < count; i++) {
      double offset = -spread + (2 * spread / (count - 1)) * i;
      shots.add(Projectile(
        x: fromX,
        y: fromY,
        dx: cos(baseAngle + offset),
        dy: sin(baseAngle + offset),
        speed: GameConstants.bulletSpeed * 0.65,
        damage: 12,
        isPlayerBullet: false,
        radius: 5.0,
        lifetime: 1.5,
      ));
    }
    return shots;
  }

  /// Látigo simbionte de Venom — 4 proyectiles en X + impacto de área
  static List<Projectile> venomTentacleShot(
      double fromX, double fromY, double toX, double toY) {
    double baseAngle = atan2(toY - fromY, toX - fromX);
    List<Projectile> shots = [];
    List<double> offsets = [-0.35, -0.12, 0.12, 0.35];
    for (double off in offsets) {
      shots.add(Projectile(
        x: fromX,
        y: fromY,
        dx: cos(baseAngle + off),
        dy: sin(baseAngle + off),
        speed: GameConstants.bulletSpeed * 0.7,
        damage: 18,
        isPlayerBullet: false,
        radius: 6.0,
        lifetime: 1.8,
        isVenom: true,
      ));
    }
    return shots;
  }
}

import '../utils/constants.dart';
import 'projectile.dart';
import '../utils/audio_manager.dart';

class Weapon {
  final WeaponType type;
  final String name;
  final double fireRate;
  final int ammoPerShot;
  double _cooldown = 0;

  Weapon({required this.type, required this.name, required this.fireRate, this.ammoPerShot = 1});

  bool get canFire => _cooldown <= 0;
  void update(double dt) { if (_cooldown > 0) _cooldown -= dt; }

  List<Projectile> fire(double fromX, double fromY, double angle) {
    if (!canFire) return [];
    _cooldown = 1.0 / fireRate;
    final audio = AudioManager();
    switch (type) {
      case WeaponType.pistol:
        audio.playShoot();
        return [Projectile.playerPistol(fromX, fromY, angle)];
      case WeaponType.shotgun:
        audio.playShotgun();
        return Projectile.playerShotgun(fromX, fromY, angle);
      case WeaponType.plasmaRifle:
        audio.playPlasma();
        return [Projectile.playerPlasma(fromX, fromY, angle)];
    }
  }

  void resetCooldown() => _cooldown = 0;

  static Weapon create(WeaponType type) {
    switch (type) {
      case WeaponType.pistol:
        // Lanzarredes básico: cadencia media, daño 20
        return Weapon(type: WeaponType.pistol, name: 'LANZARREDES', fireRate: 4.5);
      case WeaponType.shotgun:
        // Explosión de redes: cadencia baja, 5 proyectiles spread, daño 9 c/u
        return Weapon(type: WeaponType.shotgun, name: 'EXPLOSIÓN RED', fireRate: 1.2, ammoPerShot: 1);
      case WeaponType.plasmaRifle:
        // Red de impacto: cadencia MUY baja, daño 40, proyectil rápido y grande
        return Weapon(type: WeaponType.plasmaRifle, name: 'RED IMPACTO', fireRate: 2.0, ammoPerShot: 1);
    }
  }
}

class WeaponManager {
  final Map<WeaponType, Weapon> _weapons = {};
  WeaponType _currentType = WeaponType.pistol;

  WeaponManager() {
    for (var type in WeaponType.values) _weapons[type] = Weapon.create(type);
  }

  Weapon get current => _weapons[_currentType]!;
  WeaponType get currentType => _currentType;
  void switchTo(WeaponType type) => _currentType = type;
  void update(double dt) { for (var w in _weapons.values) w.update(dt); }
  List<Projectile> tryFire(double x, double y, double angle) => current.fire(x, y, angle);
}

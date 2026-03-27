import 'dart:ui';

/// Constantes globales del juego Spider-Man 2D
class GameConstants {
  static const double tileSize = 48.0;
  static const int mapWidth = 30;
  static const int mapHeight = 20;
  static const double playerSpeed = 175.0;
  static const double playerRadius = 10.0;
  static const int playerMaxHealth = 100;
  static const double playerInvulnerabilityTime = 0.8;
  static const double enemyDetectionRange = 270.0;
  static const double enemyAttackRange = 36.0;
  static const double bulletSpeed = 370.0;
  static const double bulletRadius = 4.0;
  static const double gameTickRate = 1.0 / 60.0;
  static const int totalLevels = 3;
}

class DoomColors {
  static const Color darkGray      = Color(0xFF0A0A1A);
  static const Color wallBrown     = Color(0xFF2B3A4A);
  static const Color wallDark      = Color(0xFF1C2A38);
  static const Color wallLight     = Color(0xFF3D5266);
  static const Color floor         = Color(0xFF1A1F2E);
  static const Color floorAlt      = Color(0xFF151A28);
  static const Color ceiling       = Color(0xFF0D1018);

  // Jugador
  static const Color playerBody    = Color(0xFFE53935);
  static const Color playerGun     = Color(0xFF1565C0);

  // Ladrones comunes
  static const Color thiefBody     = Color(0xFF455A64);
  static const Color thiefAccent   = Color(0xFF7B3F00);

  // Rhino (jefe N1)
  static const Color rhinoBody     = Color(0xFF546E7A);
  static const Color rhinoArmor    = Color(0xFF90A4AE);

  // Buitre (jefe N2)
  static const Color vultureBody   = Color(0xFF4E6B2E);
  static const Color vultureWing   = Color(0xFF33691E);
  static const Color vultureEye    = Color(0xFFFFD700);

  // Venom (jefe N3)
  static const Color venomBody     = Color(0xFF1A1A2E);
  static const Color venomSymbol   = Color(0xFFFFFFFF);
  static const Color venomTentacle = Color(0xFF6A0DAD);

  // Proyectiles
  static const Color bulletPlayer  = Color(0xFFE1F5FE);
  static const Color bulletShotgun = Color(0xFFB3E5FC);
  static const Color bulletPlasma  = Color(0xFF00BCD4);
  static const Color bulletEnemy   = Color(0xFFFF6F00);
  static const Color venomShot     = Color(0xFF9C27B0);
  static const Color plasma        = Color(0xFF00BCD4); // alias

  // HUD
  static const Color hudBackground = Color(0xCC0D1018);
  static const Color hudBorder     = Color(0xFF1565C0);
  static const Color healthGreen   = Color(0xFF4CAF50);
  static const Color healthYellow  = Color(0xFFFFEB3B);
  static const Color healthRed     = Color(0xFFF44336);
  static const Color ammoColor     = Color(0xFF90CAF9);
  static const Color scoreColor    = Color(0xFFFFD54F);
  static const Color textWhite     = Color(0xFFFFFFFF);
  static const Color textGray      = Color(0xFF9E9E9E);

  // Efectos
  static const Color muzzleFlash   = Color(0xFFE1F5FE);
  static const Color explosion     = Color(0xFFFF6F00);
  static const Color damageFlash   = Color(0x66CC0000);
  static const Color pickupGlow    = Color(0xFF1565C0);

  // Menú
  static const Color menuBg        = Color(0xFF0A0A1A);
  static const Color menuTitle     = Color(0xFFE53935);
  static const Color menuButton    = Color(0xFF8B0000);
  static const Color menuButtonHover = Color(0xFFB71C1C);

  // Pickups
  static const Color healthPickup  = Color(0xFF4CAF50);
  static const Color ammoPickup    = Color(0xFF1565C0);
  static const Color weaponPickup  = Color(0xFFFF9800);
  static const Color keyPickup     = Color(0xFFFFEB3B);

  // Puertas / salida
  static const Color doorColor     = Color(0xFF37474F);
  static const Color doorLocked    = Color(0xFFB71C1C);
  static const Color exitColor     = Color(0xFF00C853);
}

enum TileType {
  empty, wall, door, lockedDoor, exitTile,
  playerSpawn,
  enemySpawnImp,       // Ladrón con pistola
  enemySpawnDemon,     // Ladrón con escopeta
  enemySpawnCacodemon, // (sin uso — compatible)
  enemySpawnBoss,      // Jefe del nivel
  healthPickup, ammoPickup, weaponPickup,
}

enum GameState { menu, playing, paused, levelComplete, gameOver, victory }

enum EnemyState { idle, chasing, attacking, hurt, dying, dead }

enum WeaponType {
  pistol,       // Lanzarredes básico
  shotgun,      // Explosión de redes
  plasmaRifle,  // Red de impacto
}

enum PickupType { health, ammo, shotgunPickup, plasmaRiflePickup }

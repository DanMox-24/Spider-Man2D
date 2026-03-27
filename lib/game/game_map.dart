import 'dart:math';
import '../utils/constants.dart';
import 'enemy.dart';
import 'enemy_types.dart';
import 'pickup.dart';

/// Mapa de juego basado en tiles
class GameMap {
  final int width, height;
  final List<List<TileType>> tiles;
  double playerSpawnX = 0, playerSpawnY = 0;
  List<Enemy> enemies = [];
  List<Pickup> pickups = [];
  double exitX = 0, exitY = 0;

  static final _rnd = Random();

  GameMap({required this.width, required this.height, required this.tiles});

  TileType getTile(int col, int row) {
    if (col < 0 || col >= width || row < 0 || row >= height) return TileType.wall;
    return tiles[row][col];
  }

  bool isSolid(int col, int row) {
    TileType t = getTile(col, row);
    return t == TileType.wall || t == TileType.lockedDoor;
  }

  bool isDoor(int col, int row) {
    TileType t = getTile(col, row);
    return t == TileType.door || t == TileType.lockedDoor;
  }

  void openDoor(int col, int row) {
    if (col >= 0 && col < width && row >= 0 && row < height) {
      tiles[row][col] = TileType.empty;
    }
  }

  void spawnEntities(int levelIndex) {
    enemies.clear();
    pickups.clear();

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        double cx = col * GameConstants.tileSize + GameConstants.tileSize / 2;
        double cy = row * GameConstants.tileSize + GameConstants.tileSize / 2;

        switch (tiles[row][col]) {
          case TileType.playerSpawn:
            playerSpawnX = cx; playerSpawnY = cy;
            tiles[row][col] = TileType.empty;
            break;

          case TileType.enemySpawnImp:
            enemies.add(Imp(x: cx, y: cy));
            tiles[row][col] = TileType.empty;
            break;

          case TileType.enemySpawnDemon:
            enemies.add(Demon(x: cx, y: cy));
            tiles[row][col] = TileType.empty;
            break;

          case TileType.enemySpawnCacodemon:
            enemies.add(Imp(x: cx, y: cy));
            tiles[row][col] = TileType.empty;
            break;

          case TileType.enemySpawnBoss:
            switch (levelIndex) {
              case 0: enemies.add(RhinoBoss(x: cx, y: cy));    break;
              case 1: enemies.add(VultureBoss(x: cx, y: cy));  break;
              case 2: enemies.add(VenomBoss(x: cx, y: cy));    break;
              default: enemies.add(RhinoBoss(x: cx, y: cy));
            }
            tiles[row][col] = TileType.empty;
            break;

          case TileType.healthPickup:
            pickups.add(Pickup(x: cx, y: cy, type: PickupType.health));
            tiles[row][col] = TileType.empty;
            break;

          case TileType.ammoPickup:
            pickups.add(Pickup(x: cx, y: cy, type: PickupType.ammo));
            tiles[row][col] = TileType.empty;
            break;

          case TileType.weaponPickup:
            // Arma aleatoria: Explosión de redes o Red de impacto
            final wType = _rnd.nextBool()
                ? PickupType.shotgunPickup
                : PickupType.plasmaRiflePickup;
            pickups.add(Pickup(x: cx, y: cy, type: wType));
            tiles[row][col] = TileType.empty;
            break;

          case TileType.exitTile:
            exitX = cx; exitY = cy;
            break;

          default:
            break;
        }
      }
    }
  }

  double get pixelWidth  => width  * GameConstants.tileSize;
  double get pixelHeight => height * GameConstants.tileSize;
}

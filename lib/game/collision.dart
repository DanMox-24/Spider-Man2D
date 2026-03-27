import 'dart:math';
import '../utils/constants.dart';
import 'game_map.dart';
import 'player.dart';
import 'enemy.dart';
import 'projectile.dart';
import 'pickup.dart';

/// Collision detection system using AABB and circle-based checks
class CollisionSystem {
  final GameMap map;
  CollisionSystem(this.map);

  void resolvePlayerWallCollision(Player player) {
    double r = player.radius;
    int minCol = ((player.x - r) / GameConstants.tileSize).floor();
    int maxCol = ((player.x + r) / GameConstants.tileSize).floor();
    int minRow = ((player.y - r) / GameConstants.tileSize).floor();
    int maxRow = ((player.y + r) / GameConstants.tileSize).floor();

    for (int row = minRow; row <= maxRow; row++) {
      for (int col = minCol; col <= maxCol; col++) {
        if (map.isSolid(col, row)) {
          _resolveCircleVsRect(player, col * GameConstants.tileSize, row * GameConstants.tileSize, GameConstants.tileSize, GameConstants.tileSize);
        }
      }
    }
    player.x = player.x.clamp(r, map.pixelWidth - r);
    player.y = player.y.clamp(r, map.pixelHeight - r);
  }

  void _resolveCircleVsRect(Player player, double rx, double ry, double rw, double rh) {
    double closestX = player.x.clamp(rx, rx + rw);
    double closestY = player.y.clamp(ry, ry + rh);
    double dx = player.x - closestX;
    double dy = player.y - closestY;
    double dist = sqrt(dx * dx + dy * dy);
    if (dist < player.radius && dist > 0) {
      double overlap = player.radius - dist;
      player.x += (dx / dist) * overlap;
      player.y += (dy / dist) * overlap;
    }
  }

  void resolveEnemyWallCollision(Enemy enemy) {
    double r = enemy.radius;
    int minCol = ((enemy.x - r) / GameConstants.tileSize).floor();
    int maxCol = ((enemy.x + r) / GameConstants.tileSize).floor();
    int minRow = ((enemy.y - r) / GameConstants.tileSize).floor();
    int maxRow = ((enemy.y + r) / GameConstants.tileSize).floor();

    for (int row = minRow; row <= maxRow; row++) {
      for (int col = minCol; col <= maxCol; col++) {
        if (map.isSolid(col, row)) {
          double closestX = enemy.x.clamp(col * GameConstants.tileSize, (col + 1) * GameConstants.tileSize);
          double closestY = enemy.y.clamp(row * GameConstants.tileSize, (row + 1) * GameConstants.tileSize);
          double dx = enemy.x - closestX;
          double dy = enemy.y - closestY;
          double dist = sqrt(dx * dx + dy * dy);
          if (dist < r && dist > 0) {
            enemy.x += (dx / dist) * (r - dist);
            enemy.y += (dy / dist) * (r - dist);
          }
        }
      }
    }
    enemy.x = enemy.x.clamp(r, map.pixelWidth - r);
    enemy.y = enemy.y.clamp(r, map.pixelHeight - r);
  }

  bool projectileHitsWall(Projectile proj) {
    int col = (proj.x / GameConstants.tileSize).floor();
    int row = (proj.y / GameConstants.tileSize).floor();
    return map.isSolid(col, row);
  }

  bool circlesCollide(double x1, double y1, double r1, double x2, double y2, double r2) {
    double dx = x1 - x2, dy = y1 - y2;
    return sqrt(dx * dx + dy * dy) < (r1 + r2);
  }

  Enemy? projectileHitsEnemy(Projectile proj, List<Enemy> enemies) {
    for (var e in enemies) {
      if (!e.isActive || e.isDying) continue;
      if (circlesCollide(proj.x, proj.y, proj.radius, e.x, e.y, e.radius)) return e;
    }
    return null;
  }

  bool projectileHitsPlayer(Projectile proj, Player player) =>
      circlesCollide(proj.x, proj.y, proj.radius, player.x, player.y, player.radius);

  Enemy? playerTouchesEnemy(Player player, List<Enemy> enemies) {
    for (var e in enemies) {
      if (!e.isActive || e.isDying) continue;
      if (circlesCollide(player.x, player.y, player.radius, e.x, e.y, e.radius)) return e;
    }
    return null;
  }

  Pickup? playerTouchesPickup(Player player, List<Pickup> pickups) {
    for (var p in pickups) {
      if (!p.isActive) continue;
      if (circlesCollide(player.x, player.y, player.radius, p.x, p.y, p.radius)) return p;
    }
    return null;
  }

  bool playerOnExit(Player player) =>
      circlesCollide(player.x, player.y, player.radius, map.exitX, map.exitY, 16.0);

  bool playerNearDoor(Player player, int col, int row) {
    double doorCx = col * GameConstants.tileSize + GameConstants.tileSize / 2;
    double doorCy = row * GameConstants.tileSize + GameConstants.tileSize / 2;
    return circlesCollide(player.x, player.y, player.radius + 20, doorCx, doorCy, GameConstants.tileSize / 2);
  }
}

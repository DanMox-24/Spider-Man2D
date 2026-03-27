import '../utils/constants.dart';

/// Representa un ítem recogible en el mundo
class Pickup {
  double x, y;
  PickupType type;
  bool isActive;
  double bobTimer;
  final double radius = 10.0;

  Pickup({required this.x, required this.y, required this.type,
      this.isActive = true, this.bobTimer = 0});

  void update(double dt) => bobTimer += dt * 3.0;
  double get bobOffset => 3.0 * (bobTimer % 6.283).abs();
  void collect() => isActive = false;
}

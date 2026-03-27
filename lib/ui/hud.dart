import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../game/game_engine.dart';
import '../game/player.dart';

/// HUD del juego con información de salud, munición, puntos y enemigos restantes
class HudOverlay extends StatelessWidget {
  final GameEngine engine;
  const HudOverlay({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final player = engine.player;

    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Stack(
            children: [
              // Barra inferior del HUD
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 85,
                  decoration: BoxDecoration(
                    color: DoomColors.hudBackground,
                    border: const Border(
                        top: BorderSide(color: DoomColors.hudBorder, width: 2)),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHealthSection(player),
                        const Spacer(),
                        _buildWeaponSection(player),
                        const Spacer(),
                        _buildScoreSection(player),
                        const SizedBox(width: 12),
                        _buildZoneInfo(),
                      ],
                    ),
                  ),
                ),
              ),

              // Contador de enemigos restantes (superior izquierda)
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: DoomColors.hudBackground,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: DoomColors.hudBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pest_control,
                          color: DoomColors.healthRed, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${engine.enemiesRemaining}',
                        style: const TextStyle(
                          color: DoomColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'enemigos',
                        style: TextStyle(
                            color: DoomColors.textGray,
                            fontSize: 11,
                            fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSection(Player player) {
    double hp = player.health / player.maxHealth;
    Color healthColor = hp > 0.6
        ? DoomColors.healthGreen
        : hp > 0.3
            ? DoomColors.healthYellow
            : DoomColors.healthRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Icon(Icons.favorite, color: healthColor, size: 17),
          const SizedBox(width: 5),
          Text(
            '${player.health}',
            style: TextStyle(
                color: healthColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace'),
          ),
        ]),
        const SizedBox(height: 2),
        SizedBox(
          width: 95,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: hp,
              backgroundColor: Colors.black54,
              valueColor: AlwaysStoppedAnimation(healthColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeaponSection(Player player) {
    String weaponName;
    Color weaponColor;
    int ammo;
    IconData weaponIcon;
    Color iconColor;

    switch (player.currentWeapon) {
      case WeaponType.pistol:
        weaponName = 'LANZARREDES';
        weaponColor = Colors.white;
        ammo = -1;
        weaponIcon = Icons.water_drop;
        iconColor = Colors.white70;
        break;
      case WeaponType.shotgun:
        weaponName = 'EXPLOSIÓN RED';
        weaponColor = const Color(0xFF90CAF9);
        ammo = player.ammo[WeaponType.shotgun] ?? 0;
        weaponIcon = Icons.burst_mode;
        iconColor = const Color(0xFF90CAF9);
        break;
      case WeaponType.plasmaRifle:
        weaponName = 'RED IMPACTO';
        weaponColor = const Color(0xFF00BCD4);
        ammo = player.ammo[WeaponType.plasmaRifle] ?? 0;
        weaponIcon = Icons.bolt;
        iconColor = const Color(0xFF00BCD4);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: weaponColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: weaponColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nombre del arma + ícono
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(weaponIcon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(
                weaponName,
                style: TextStyle(
                    color: weaponColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 3),
          // Munición
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: DoomColors.ammoColor, size: 10),
              const SizedBox(width: 4),
              Text(
                ammo == -1 ? '∞' : '$ammo',
                style: const TextStyle(
                    color: DoomColors.ammoColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(Player player) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('PUNTOS',
            style: TextStyle(
                color: DoomColors.textGray,
                fontSize: 10,
                fontFamily: 'monospace')),
        Text('${player.score}',
            style: const TextStyle(
                color: DoomColors.scoreColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildZoneInfo() {
    const zoneNames = ['Bugle', 'Oscorp', 'Guarida'];
    String name = engine.currentLevel < zoneNames.length
        ? zoneNames[engine.currentLevel]
        : 'Z${engine.currentLevel + 1}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: DoomColors.hudBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('ZONA',
              style: TextStyle(
                  color: DoomColors.textGray,
                  fontSize: 9,
                  fontFamily: 'monospace')),
          Text('${engine.currentLevel + 1}',
              style: const TextStyle(
                  color: DoomColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
          Text(name,
              style: const TextStyle(
                  color: DoomColors.textGray,
                  fontSize: 8,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

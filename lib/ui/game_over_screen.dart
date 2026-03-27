import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Pantallas de Game Over, Victoria y Nivel Completo
class GameOverScreen extends StatelessWidget {
  final int score, level, kills;
  final bool isVictory;
  final VoidCallback onRestart, onMenu;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.level,
    required this.kills,
    required this.isVictory,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Colors.black.withOpacity(0.88),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Título
                    Text(
                      isVictory ? '¡CIUDAD SALVADA!' : '¡SPIDER-MAN CAÍDO!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isVictory ? 40 : 34,
                        fontWeight: FontWeight.w900,
                        color: isVictory
                            ? DoomColors.exitColor
                            : DoomColors.menuTitle,
                        letterSpacing: 4,
                        fontFamily: 'monospace',
                        shadows: [
                          Shadow(
                            color: (isVictory
                                    ? DoomColors.exitColor
                                    : DoomColors.menuTitle)
                                .withOpacity(0.6),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      isVictory
                          ? '¡Todos los villanos derrotados!'
                          : 'La ciudad te necesita...',
                      style: const TextStyle(
                        color: DoomColors.textGray,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Estadísticas
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: DoomColors.hudBackground,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: DoomColors.hudBorder, width: 2),
                      ),
                      child: Column(
                        children: [
                          _statRow(
                              'PUNTUACIÓN', '$score', DoomColors.scoreColor),
                          const SizedBox(height: 10),
                          _statRow(
                              'ZONA', '${level + 1}', DoomColors.textWhite),
                          const SizedBox(height: 10),
                          _statRow('VILLANOS', '$kills', DoomColors.healthRed),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Botones
                    _buildButton(context, 'JUGAR DE NUEVO', onRestart,
                        DoomColors.menuButton),
                    const SizedBox(height: 12),
                    _buildButton(context, 'MENÚ PRINCIPAL', onMenu,
                        const Color(0xFF263238)),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(
                  color: DoomColors.textGray,
                  fontSize: 15,
                  fontFamily: 'monospace')),
        ),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildButton(
      BuildContext context, String text, VoidCallback onPressed, Color color) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.8), width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla de zona completada — entre niveles
class LevelCompleteScreen extends StatelessWidget {
  final int level, kills, score;
  final VoidCallback onNextLevel;

  const LevelCompleteScreen({
    super.key,
    required this.level,
    required this.kills,
    required this.score,
    required this.onNextLevel,
  });

  static const _levelNames = [
    'Tejado del Daily Bugle',
    'Torre Oscorp',
    'Guarida de Venom'
  ];

  @override
  Widget build(BuildContext context) {
    final name =
        level < _levelNames.length ? _levelNames[level] : 'Zona ${level + 1}';

    return Container(
      color: Colors.black.withOpacity(0.88),
      child: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    '¡ZONA DESPEJADA!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: DoomColors.exitColor,
                      letterSpacing: 5,
                      fontFamily: 'monospace',
                      shadows: [
                        Shadow(color: DoomColors.exitColor, blurRadius: 24)
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(name,
                      style: const TextStyle(
                          color: DoomColors.textGray,
                          fontSize: 13,
                          fontFamily: 'monospace',
                          letterSpacing: 2)),
                  const SizedBox(height: 28),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DoomColors.hudBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DoomColors.hudBorder, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text('ZONA ${level + 1} COMPLETADA',
                            style: const TextStyle(
                                color: DoomColors.textWhite,
                                fontSize: 16,
                                fontFamily: 'monospace')),
                        const SizedBox(height: 10),
                        Text('Villanos: $kills  •  Puntos: $score',
                            style: const TextStyle(
                                color: DoomColors.scoreColor,
                                fontSize: 14,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  GestureDetector(
                    onTap: onNextLevel,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.55,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF006600),
                            Color(0xFF00AA00),
                            Color(0xFF006600)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: DoomColors.exitColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: DoomColors.exitColor.withOpacity(0.4),
                              blurRadius: 16)
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'SIGUIENTE ZONA',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

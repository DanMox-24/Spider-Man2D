import 'dart:math';
import 'package:flutter/material.dart';

class MainMenuScreen extends StatefulWidget {
  final VoidCallback onStartGame;
  const MainMenuScreen({super.key, required this.onStartGame});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _pulse, _glow;

  @override
  void initState() {
    super.initState();
    _anim =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.07)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 0.3, end: 0.9)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A1A), Color(0xFF0D1A2E), Color(0xFF0A0A1A)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) =>
                  CustomPaint(painter: _WebBgPainter(_anim.value)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Transform.scale(
                    scale: _pulse.value,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFE53935),
                              Color.fromRGBO(183, 28, 28, _glow.value + 0.1),
                              const Color(0xFFFF5252)
                            ],
                          ).createShader(b),
                          child: const Text('SPIDER-MAN',
                              style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 8,
                                  fontFamily: 'monospace',
                                  shadows: [
                                    Shadow(
                                        color: Color(0xFFE53935),
                                        blurRadius: 30),
                                    Shadow(
                                        color: Color(0xFF8B0000),
                                        blurRadius: 60)
                                  ])),
                        ),
                        Text('2D  •  ATAQUE A LA CIUDAD',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(
                                    21, 101, 192, _glow.value + 0.2),
                                letterSpacing: 7,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => CustomPaint(
                        size: const Size(80, 80),
                        painter: _SpiderLogoPainter(_glow.value))),
                const SizedBox(height: 38),
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => GestureDetector(
                    onTap: widget.onStartGame,
                    child: Container(
                      width: 260,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFF8B0000),
                          Color(0xFFE53935),
                          Color(0xFF8B0000)
                        ]),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: Color.fromRGBO(255, 82, 82, _glow.value),
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(
                                  229, 57, 53, _glow.value * 0.5),
                              blurRadius: 22,
                              spreadRadius: 2)
                        ],
                      ),
                      child: const Center(
                          child: Text('NUEVA PARTIDA',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 5,
                                  fontFamily: 'monospace'))),
                    ),
                  ),
                ),
                const SizedBox(height: 70),
                const Text('HECHO CON FLUTTER  •  SIN MOTORES EXTERNOS',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF444455),
                        letterSpacing: 3,
                        fontFamily: 'monospace')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebBgPainter extends CustomPainter {
  final double t;
  _WebBgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final nodes = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.05),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width * 0.8, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.85)
    ];
    for (var node in nodes) {
      for (int ring = 1; ring <= 4; ring++)
        canvas.drawCircle(node, ring * 30.0 + sin(t * pi + ring) * 4, paint);
      for (int spoke = 0; spoke < 8; spoke++) {
        double a = spoke * pi / 4 + t * 0.5;
        canvas.drawLine(node, node + Offset(cos(a) * 130, sin(a) * 130), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_WebBgPainter old) => true;
}

class _SpiderLogoPainter extends CustomPainter {
  final double glow;
  _SpiderLogoPainter(this.glow);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final bp = Paint()..color = Color.fromRGBO(229, 57, 53, glow);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 36), bp);
    canvas.drawCircle(Offset(cx, cy - 22), 10, bp);
    final lp = Paint()
      ..color = Color.fromRGBO(229, 57, 53, glow * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final legs = [
      [
        Offset(cx - 8, cy - 10),
        Offset(cx - 30, cy - 22),
        Offset(cx - 36, cy - 10)
      ],
      [
        Offset(cx - 8, cy - 2),
        Offset(cx - 32, cy - 2),
        Offset(cx - 38, cy + 10)
      ],
      [
        Offset(cx - 8, cy + 6),
        Offset(cx - 28, cy + 14),
        Offset(cx - 34, cy + 26)
      ],
      [
        Offset(cx - 8, cy + 14),
        Offset(cx - 22, cy + 28),
        Offset(cx - 24, cy + 38)
      ],
      [
        Offset(cx + 8, cy - 10),
        Offset(cx + 30, cy - 22),
        Offset(cx + 36, cy - 10)
      ],
      [
        Offset(cx + 8, cy - 2),
        Offset(cx + 32, cy - 2),
        Offset(cx + 38, cy + 10)
      ],
      [
        Offset(cx + 8, cy + 6),
        Offset(cx + 28, cy + 14),
        Offset(cx + 34, cy + 26)
      ],
      [
        Offset(cx + 8, cy + 14),
        Offset(cx + 22, cy + 28),
        Offset(cx + 24, cy + 38)
      ]
    ];
    for (var leg in legs) {
      final path = Path()
        ..moveTo(leg[0].dx, leg[0].dy)
        ..lineTo(leg[1].dx, leg[1].dy)
        ..lineTo(leg[2].dx, leg[2].dy);
      canvas.drawPath(path, lp);
    }
  }

  @override
  bool shouldRepaint(_SpiderLogoPainter old) => true;
}

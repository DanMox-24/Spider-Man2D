import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Controles táctiles con joystick flotante y botones de acción para disparar y cambiar arma
class TouchControls extends StatefulWidget {
  final Function(double dx, double dy) onMove;
  final Function(bool shooting) onShoot;
  final VoidCallback onSwitchWeapon;

  const TouchControls({
    super.key,
    required this.onMove,
    required this.onShoot,
    required this.onSwitchWeapon,
  });

  @override
  State<TouchControls> createState() => _TouchControlsState();
}

class _TouchControlsState extends State<TouchControls> {
  // ── Joystick flotante ──────────────────────────────────────────────────
  Offset? _joystickOrigin; // centro del joystick — se fija al primer toque
  Offset _joystickKnob = Offset.zero; // desplazamiento del knob
  int? _joystickPointer;
  bool _isShooting = false;

  static const double joystickRadius = 55.0;
  static const double knobRadius = 22.0;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final halfW = screenW / 2;

    return Stack(
      children: [
        // ── ZONA IZQUIERDA: joystick flotante ─────────────────────────────
        Positioned(
          left: 0,
          top: 0,
          width: halfW,
          height: screenH,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (e) {
              if (_joystickPointer != null) return;
              final local = e.localPosition;
              _joystickPointer = e.pointer;
              setState(() {
                _joystickOrigin = local;
                _joystickKnob = Offset.zero;
              });
              widget.onMove(0, 0);
            },
            onPointerMove: (e) {
              if (e.pointer != _joystickPointer) return;
              _updateJoystick(e.localPosition);
            },
            onPointerUp: (e) => _releaseJoystick(e.pointer),
            onPointerCancel: (e) => _releaseJoystick(e.pointer),
            child: CustomPaint(
              painter: _JoystickPainter(
                origin: _joystickOrigin,
                knobOffset: _joystickKnob,
                radius: joystickRadius,
                knobRadius: knobRadius,
              ),
            ),
          ),
        ),

        // ── ZONA DERECHA: botones de acción ───────────────────────────────
        Positioned(
          right: 20,
          bottom: 85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón cambiar arma
              GestureDetector(
                onTap: widget.onSwitchWeapon,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DoomColors.weaponPickup.withOpacity(0.3),
                    border: Border.all(
                        color: DoomColors.weaponPickup.withOpacity(0.7),
                        width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.swap_horiz,
                        color: DoomColors.weaponPickup, size: 26),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Botón disparar
              Listener(
                onPointerDown: (_) {
                  setState(() => _isShooting = true);
                  widget.onShoot(true);
                },
                onPointerUp: (_) {
                  setState(() => _isShooting = false);
                  widget.onShoot(false);
                },
                onPointerCancel: (_) {
                  setState(() => _isShooting = false);
                  widget.onShoot(false);
                },
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isShooting
                        ? const Color(0xFF1565C0).withOpacity(0.75)
                        : const Color(0xFF1565C0).withOpacity(0.3),
                    border: Border.all(
                      color: _isShooting
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF1565C0).withOpacity(0.6),
                      width: 3,
                    ),
                    boxShadow: _isShooting
                        ? [
                            BoxShadow(
                                color: const Color(0xFF1565C0).withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 4)
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.water_drop,
                      color:
                          _isShooting ? Colors.white : const Color(0xFF90CAF9),
                      size: 38,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateJoystick(Offset localPos) {
    if (_joystickOrigin == null) return;
    double dx = localPos.dx - _joystickOrigin!.dx;
    double dy = localPos.dy - _joystickOrigin!.dy;
    double dist = sqrt(dx * dx + dy * dy);

    if (dist > joystickRadius) {
      dx = dx / dist * joystickRadius;
      dy = dy / dist * joystickRadius;
      dist = joystickRadius;
    }

    setState(() => _joystickKnob = Offset(dx, dy));

    double nx = dx / joystickRadius;
    double ny = dy / joystickRadius;
    if (dist < 8) {
      nx = 0;
      ny = 0;
    }
    widget.onMove(nx, ny);
  }

  void _releaseJoystick(int pointer) {
    if (pointer != _joystickPointer) return;
    _joystickPointer = null;
    setState(() {
      _joystickOrigin = null;
      _joystickKnob = Offset.zero;
    });
    widget.onMove(0, 0);
  }
}

/// Pinta el joystick flotante en canvas
class _JoystickPainter extends CustomPainter {
  final Offset? origin;
  final Offset knobOffset;
  final double radius;
  final double knobRadius;

  _JoystickPainter({
    required this.origin,
    required this.knobOffset,
    required this.radius,
    required this.knobRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (origin == null) {
      // Sin toque activo: mostrar indicador sutil
      canvas.drawCircle(
        Offset(size.width * 0.35, size.height * 0.72),
        28,
        Paint()
          ..color = Colors.white.withOpacity(0.07)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      return;
    }

    // Base del joystick
    canvas.drawCircle(
      origin!,
      radius,
      Paint()..color = Colors.black.withOpacity(0.35),
    );
    canvas.drawCircle(
      origin!,
      radius,
      Paint()
        ..color = const Color(0xFF1565C0).withOpacity(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Knob
    final knobCenter = origin! + knobOffset;
    canvas.drawCircle(
      knobCenter,
      knobRadius,
      Paint()..color = const Color(0xFFE53935).withOpacity(0.7),
    );
    canvas.drawCircle(
      knobCenter,
      knobRadius,
      Paint()
        ..color = const Color(0xFFE53935)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_JoystickPainter old) =>
      old.origin != origin || old.knobOffset != knobOffset;
}

import 'package:flutter/material.dart';
import 'package:mathosproject/sound_manager.dart';
import 'dart:math';
import 'dart:async';

class PixelCircle extends StatefulWidget {
  final Color color;
  final double size;
  final Widget child;
  final VoidCallback onPressed;

  const PixelCircle({
    Key? key,
    required this.color,
    required this.size,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  _PixelCircleState createState() => _PixelCircleState();
}

class _PixelCircleState extends State<PixelCircle> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) async {
        setState(() => _isPressed = true);
        // Appel du SoundManager pour jouer le son au clic
        await SoundManager.playButtonClickSound();
      },
      onTapUp: (_) {
        Timer(Duration(milliseconds: 150), () {
          setState(() => _isPressed = false);
          widget.onPressed();
        });
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: CustomPaint(
        painter: PixelCirclePainter(
          color: _isPressed ? Colors.yellow : widget.color,
          isPressed: _isPressed,
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class PixelCirclePainter extends CustomPainter {
  final Color color;
  final bool isPressed;

  PixelCirclePainter({required this.color, required this.isPressed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final pixelSize = size.width / 30;
    final center = size.width / 2;
    final radius = size.width / 2;

    final lightColor = color.withOpacity(1.0);
    final darkColor = color.withOpacity(0.6);
    final borderColor = Colors.black;

    // Dessiner la bordure noire pixelisée
    for (var y = 0; y < 30; y++) {
      for (var x = 0; x < 30; x++) {
        final dx = (x * pixelSize + pixelSize / 2) - center;
        final dy = (y * pixelSize + pixelSize / 2) - center;
        final distance = dx * dx + dy * dy;

        if (distance <= radius * radius && distance >= (radius - pixelSize) * (radius - pixelSize)) {
          paint.color = borderColor;
          canvas.drawRect(
            Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
            paint,
          );
        }
      }
    }

    // Appliquer le dégradé et l'effet de pression
    for (var y = 0; y < 30; y++) {
      for (var x = 0; x < 30; x++) {
        final dx = (x * pixelSize + pixelSize / 2) - center;
        final dy = (y * pixelSize + pixelSize / 2) - center;
        final distance = dx * dx + dy * dy;

        if (distance < (radius - pixelSize) * (radius - pixelSize)) {
          double distanceFromBorder = (radius - pixelSize) - sqrt(distance);

          if ((dy < 0 || dy > 0) && distanceFromBorder < 3 * pixelSize) {
            double factor = distanceFromBorder / (3 * pixelSize);
            paint.color = Color.lerp(darkColor, color, factor)!;
          } else {
            paint.color = color;
          }

          canvas.drawRect(
            Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Cast oldDelegate to PixelCirclePainter to access color and isPressed
    return oldDelegate is PixelCirclePainter &&
        (color != oldDelegate.color || isPressed != oldDelegate.isPressed);
  }
}

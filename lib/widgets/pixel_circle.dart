import 'package:flutter/material.dart';
import 'dart:math'; // Import for sqrt function

class PixelCircle extends StatelessWidget {
  final Color color;
  final double size;
  final Widget child;

  const PixelCircle({
    Key? key,
    required this.color,
    required this.size,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PixelCirclePainter(color: color),
      child: Container(
        width: size,
        height: size,
        child: Center(child: child), // Centrer le contenu à l'intérieur du bouton
      ),
    );
  }
}

class PixelCirclePainter extends CustomPainter {
  final Color color;

  PixelCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final pixelSize = size.width / 30; // Nombre de pixels dans le cercle
    final center = size.width / 2;
    final radius = size.width / 2;

    // Couleurs pour la lumière et l'ombre
    final lightColor = color.withOpacity(1.0); // Couleur plus claire pour l'intérieur
    final darkColor = color.withOpacity(0.3);  // Couleur plus sombre pour la bordure
    final borderColor = Colors.black;          // Couleur de la bordure noire

    // Dessiner la bordure noire pixelisée autour du cercle
    for (var y = 0; y < 30; y++) {
      for (var x = 0; x < 30; x++) {
        final dx = (x * pixelSize + pixelSize / 2) - center;
        final dy = (y * pixelSize + pixelSize / 2) - center;
        final distance = dx * dx + dy * dy;

        // Bordure noire pixelisée
        if (distance <= radius * radius && distance >= (radius - pixelSize) * (radius - pixelSize)) {
          paint.color = borderColor;
          canvas.drawRect(
            Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
            paint,
          );
        }
      }
    }

    // Appliquer un éclaircissement progressif à l'intérieur du cercle
    for (var y = 0; y < 30; y++) {
      for (var x = 0; x < 30; x++) {
        final dx = (x * pixelSize + pixelSize / 2) - center;
        final dy = (y * pixelSize + pixelSize / 2) - center;
        final distance = sqrt(dx * dx + dy * dy); // Distance radiale du centre

        // Si le pixel est à l'intérieur du cercle, on applique l'effet radial
        if (distance < (radius - pixelSize)) {
          double factor = 1 - (distance / radius); // Inverser le facteur pour avoir sombre à la bordure
          factor = factor.clamp(0.0, 1.0); // Limiter le facteur entre 0 et 1

          // Appliquer un dégradé radial inversé (plus sombre à la bordure, plus clair au centre)
          paint.color = Color.lerp(darkColor, lightColor, factor)!;

          canvas.drawRect(
            Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

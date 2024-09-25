import 'package:flutter/material.dart';

class PixelTransition extends PageRouteBuilder {
  final Widget page;

  PixelTransition({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return ClipPath(
            clipper: PixelClipper(animation.value),
            child: child,
          );
        },
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 500), // Durée de l'animation
  );
}

class PixelClipper extends CustomClipper<Path> {
  final double progress;

  PixelClipper(this.progress);

  @override
  Path getClip(Size size) {
    Path path = Path();
    int rows = 20;
    int columns = 30;
    double tileWidth = size.width / columns;
    double tileHeight = size.height / rows;

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        double chance = (i + j) / (rows + columns);
        if (progress > chance) {
          path.addRect(Rect.fromLTWH(
            j * tileWidth,
            i * tileHeight,
            tileWidth,
            tileHeight,
          ));
        }
      }
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
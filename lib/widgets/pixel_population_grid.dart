import 'dart:math';

import 'package:flutter/material.dart';

class PixelPopulationGrid extends StatefulWidget {
  final int currentLevel;
  final Size screenSize;

  PixelPopulationGrid({
    required this.currentLevel,
    required this.screenSize,
  });

  @override
  _PixelPopulationGridState createState() => _PixelPopulationGridState();
}

class _PixelPopulationGridState extends State<PixelPopulationGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int getPercentile(int level) {
    switch (level) {
      case 1: return 15;
      case 2: return 30;
      case 3: return 50;
      case 4: return 60;
      case 5: return 70;
      case 6: return 80;
      case 7: return 90;
      case 8: return 95;
      case 9: return 98;
      case 10: return 99;
      default: return 0;
    }
  }

  (int width, int height) calculateDimensions(int topPercentage) {
    int totalCells = (100 - topPercentage).round();

    // Cas spéciaux pour les très petits nombres
    if (totalCells <= 2) {
      return (1, totalCells); // Pour 1% et 2%
    }

    // Pour les nombres jusqu'à 5
    if (totalCells <= 5) {
      return (totalCells, 1);
    }

    // Pour tous les autres cas, trouve la meilleure configuration rectangulaire
    List<(int, int)> possibleConfigs = [];

    for (int i = 1; i <= sqrt(totalCells).ceil(); i++) {
      if (totalCells % i == 0) {
        int width = totalCells ~/ i;
        int height = i;

        if (height <= 10 && width <= 10) {
          possibleConfigs.add((width, height));
        }
      }
    }

    // Trouve la configuration la plus proche d'un carré
    (int, int) bestConfig = possibleConfigs.first;
    double bestRatioDiff = double.infinity;

    for (var config in possibleConfigs) {
      double ratio = config.$1 / config.$2;
      double ratioDiff = (ratio - 1).abs();

      if (ratioDiff < bestRatioDiff) {
        bestRatioDiff = ratioDiff;
        bestConfig = config;
      }
    }

    // Si la hauteur est plus grande que la largeur, inverse
    if (bestConfig.$2 > bestConfig.$1) {
      return (bestConfig.$2, bestConfig.$1);
    }

    return bestConfig;
  }

  String getTopText(int level) {
    if (level == 0) {
      return "Allez dans le mode progression\npour évaluer votre niveau";
    }
    return "TOP ${100 - getPercentile(level)}%";
  }

  @override
  Widget build(BuildContext context) {
    double availableSpace = widget.screenSize.height * 0.4;
    double containerSize = availableSpace * 0.9;

    int percentileBeat = getPercentile(widget.currentLevel);
    var (rectWidth, rectHeight) = calculateDimensions(percentileBeat);

    return Center(
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          border: Border.all(color: Colors.yellow, width: 4),
        ),
        child: Stack(
          children: [
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                childAspectRatio: 1,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 100,
              padding: EdgeInsets.all(2),
              itemBuilder: (context, index) => _buildCharacter(containerSize / 10),
            ),

            if (widget.currentLevel > 0)
              Positioned(
                top: 2,
                left: 2,
                width: containerSize * (rectWidth / 10),
                height: containerSize * (rectHeight / 10),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(_controller.value * 0.7),
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              getTopText(widget.currentLevel),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'PixelFont',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacter(double size) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: Border.all(
          color: Colors.grey[900]!,
          width: 1,
        ),
      ),
      child: CustomPaint(
        painter: PixelCharacterPainter(),
      ),
    );
  }
}

class PixelCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.grey[600]!;

    double margin = size.width * 0.1;
    canvas.drawRect(
      Rect.fromLTWH(
        margin,
        margin,
        size.width - 2 * margin,
        size.height - 2 * margin,
      ),
      paint,
    );

    paint.color = Colors.black;
    double eyeSize = size.width * 0.15;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.3, eyeSize, eyeSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.3, eyeSize, eyeSize),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.6,
        size.width * 0.4,
        size.height * 0.05,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
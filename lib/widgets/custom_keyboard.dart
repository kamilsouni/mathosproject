import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onDelete;
  final double keySpacing;
  final double fontSizeFactor;

  CustomKeyboard({
    required this.controller,
    required this.onSubmit,
    required this.onDelete,
    this.keySpacing = 4.0,
    this.fontSizeFactor = 0.6,
  });

  Widget _buildKey(String label) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(keySpacing),
        child: ElevatedButton(
          onPressed: () {
            controller.text += label;
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.yellow,
            backgroundColor: Colors.white, // Color(0xFF8B4513) marron
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.black, width: 2),
            padding: EdgeInsets.zero,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double fontSize = constraints.biggest.shortestSide * fontSizeFactor;
              return FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'VT323',
                    fontSize: fontSize+30,
                    color: Colors.black,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(String label, VoidCallback onTap, Color color) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(keySpacing),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.black, width: 1),
            padding: EdgeInsets.zero,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double fontSize = constraints.biggest.shortestSide * fontSizeFactor * 0.22;
              return FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: label.split('').map((char) => Text(
                    char,
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      fontSize: fontSize,
                      color: Colors.white,
                    ),
                  )).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculer la hauteur idéale du clavier (par exemple, 40% de la hauteur de l'écran)
        double keyboardHeight = constraints.maxHeight * 0.2;
        // Assurer une hauteur minimale pour la lisibilité
        keyboardHeight = keyboardHeight.clamp(200.0, 250.0);

        return Container(
          height: keyboardHeight,
          decoration: BoxDecoration(
            color: Color(0xFF02A6CC), //vert Color(0xFF2F4F4F)
            border: Border(
              top: BorderSide(color: Colors.black, width: 2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(children: [_buildKey('1'), _buildKey('2'), _buildKey('3')]),
                    ),
                    Expanded(
                      child: Row(children: [_buildKey('4'), _buildKey('5'), _buildKey('6')]),
                    ),
                    Expanded(
                      child: Row(children: [_buildKey('7'), _buildKey('8'), _buildKey('9')]),
                    ),
                    Expanded(
                      child: Row(children: [_buildKey('0')]),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildActionKey('CORRIGER', onDelete, Colors.orange),
                    _buildActionKey('PASSER', onSubmit, Colors.redAccent),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
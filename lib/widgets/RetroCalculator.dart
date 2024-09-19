import 'package:flutter/material.dart';
import 'package:mathosproject/widgets/custom_keyboard.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Import auto_size_text pour ajuster la taille du texte

class RetroCalculator extends StatelessWidget {
  final String question;
  final String answer;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onDelete;
  final bool isCorrectAnswer;
  final bool isSkipped;

  RetroCalculator({
    required this.question,
    required this.answer,
    required this.controller,
    required this.onSubmit,
    required this.onDelete,
    this.isCorrectAnswer = false,
    this.isSkipped = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth * 0.1; // Calcul de la taille de police en fonction de la largeur

        return Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF02A6CC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Partie supérieure de la calculette
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF02A6CC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ),

              // Écran de la calculette avec ajustement de la taille de police
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isCorrectAnswer ? Colors.green[200]! :
                      isSkipped ? Colors.red[200]! : Color(0xFFCCCDBF),
                      isCorrectAnswer ? Colors.green[100]! :
                      isSkipped ? Colors.red[100]! : Color(0xFFBBBCAE),
                    ],
                  ),
                  border: Border.all(color: Colors.black, width: 4),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AutoSizeText(
                      question,
                      style: TextStyle(
                        fontFamily: 'VT323',
                        fontSize: fontSize + 10, // Ajustement de la taille de police
                        color: Colors.black87,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black26,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1, // S'assurer que le texte tient sur une ligne
                      minFontSize: 10, // Taille minimale du texte
                    ),
                    SizedBox(height: 8),
                    AutoSizeText(
                      answer,
                      style: TextStyle(
                        fontFamily: 'VT323',
                        fontSize: fontSize + 10,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black26,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1, // S'assurer que le texte tient sur une ligne
                      minFontSize: 10, // Taille minimale du texte
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Clavier personnalisé
              Expanded(
                child: CustomKeyboard(
                  controller: controller,
                  onSubmit: onSubmit,
                  onDelete: onDelete,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mathosproject/widgets/custom_keyboard.dart';

class RetroCalculator extends StatelessWidget {
  final String question;
  final String answer;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onDelete;
  final bool isCorrectAnswer;
  final bool isSkipped;
  final bool isEquationMode;
  final bool isRapidMode;
  final bool isProgressMode;

  RetroCalculator({
    required this.question,
    required this.answer,
    required this.controller,
    required this.onSubmit,
    required this.onDelete,
    this.isCorrectAnswer = false,
    this.isSkipped = false,
    this.isEquationMode = false,
    this.isRapidMode = false,
    this.isProgressMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Utilisation de MediaQuery pour obtenir la taille de l'écran
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Calcul dynamique de la taille de la police en fonction de l'écran
    double fontSizeForQuestion = screenHeight * 0.08; // 8% de la hauteur de l'écran
    double fontSizeForAnswer = screenHeight * 0.06; // 6% de la hauteur de l'écran

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
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isCorrectAnswer
                        ? Colors.green[200]!
                        : isSkipped
                        ? Colors.red[200]!
                        : Color(0xFFCCCDBF),
                    isCorrectAnswer
                        ? Colors.green[100]!
                        : isSkipped
                        ? Colors.red[100]!
                        : Color(0xFFBBBCAE),
                  ],
                ),
                border: Border.all(color: Colors.black, width: 4),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        question,
                        style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: fontSizeForQuestion, // Utilisation de la taille dynamique
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      answer,
                      style: TextStyle(
                        fontFamily: 'VT323',
                        fontSize: fontSizeForAnswer, // Taille dynamique pour la réponse
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
  }
}

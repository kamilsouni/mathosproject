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
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenHeight = constraints.maxHeight;
        double screenWidth = constraints.maxWidth;

        // Déterminer la taille de police en fonction de la longueur du texte
        double fontSizeForQuestion = _calculateFontSize(question, screenHeight, screenWidth);
        double fontSizeForAnswer = screenHeight * 0.08; // Taille fixe pour la réponse

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
                          child: SingleChildScrollView(
                            child: Text(
                              question,
                              style: TextStyle(
                                fontFamily: 'VT323',
                                fontSize: fontSizeForQuestion,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          answer,
                          style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: fontSizeForAnswer,
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
      },
    );
  }

  double _calculateFontSize(String text, double height, double width) {
    if (text.length <= 25) {
      // Pour les opérations courtes (mode Rapidity)
      return height * 0.1; // Grande taille de police
    } else if (text.length <= 50) {
      // Pour les textes de longueur moyenne
      return height * 0.055;
    } else {
      // Pour les longs textes (mode Problem)
      return height * 0.040; // Taille de police plus petite
    }
  }
}
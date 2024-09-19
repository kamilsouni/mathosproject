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
  final bool isEquationMode; // Nouveau paramètre pour distinguer le mode Équation


  RetroCalculator({
    required this.question,
    required this.answer,
    required this.controller,
    required this.onSubmit,
    required this.onDelete,
    this.isCorrectAnswer = false,
    this.isSkipped = false,
    this.isEquationMode = false, // Par défaut, on considère que c'est le mode Problème

  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                    children: [
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: AutoSizeText(
                            question,
                            style: TextStyle(
                              fontFamily: 'VT323',
                              color: Colors.black87,
                            ),
                            maxLines: isEquationMode ? 1 : 5, // Une seule ligne pour les équations, plusieurs pour les problèmes
                            minFontSize: 10,
                            maxFontSize: isEquationMode ? 48 : 24, // Plus grande taille pour les équations
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: AutoSizeText(
                          answer,
                          style: TextStyle(
                            fontFamily: 'VT323',
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          minFontSize: 10,
                          maxFontSize: 24,
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
}
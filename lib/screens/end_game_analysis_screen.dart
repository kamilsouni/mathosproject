import 'package:flutter/material.dart';
import 'dart:async';

class EndGameAnalysisScreen extends StatefulWidget {
  final int score;
  final List<Map<String, dynamic>> operationsHistory;
  final int initialRecord;

  EndGameAnalysisScreen({
    required this.score,
    required this.operationsHistory,
    required this.initialRecord,
  });

  @override
  _EndGameAnalysisScreenState createState() => _EndGameAnalysisScreenState();
}

class _EndGameAnalysisScreenState extends State<EndGameAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late Animation<int> _scoreAnimation;
  int _currentOperationIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeScoreAnimation();
    _playOperationsAnimation();
  }

  void _initializeScoreAnimation() {
    _scoreAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _scoreAnimationController.forward();
  }

  void _playOperationsAnimation() {
    Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (_currentOperationIndex < widget.operationsHistory.length - 1) {
        setState(() {
          _currentOperationIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculer la taille du texte des opérations de manière adaptative
    double operationFontSize = screenWidth * 0.04;
    double scoreFontSize = screenWidth * 0.08;

    if (widget.operationsHistory.length > 10) {
      operationFontSize *= 0.85; // Réduire la taille si trop d'opérations
    }

    return Scaffold(
      body: Container(
        color: Color(0xFF564560),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Score placé à 1 cm du haut de l'écran
              SizedBox(height: screenHeight * 0.01),
              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Score: ${_scoreAnimation.value}',
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: scoreFontSize, // Ajuste la taille pour éviter le retour à la ligne
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.01),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _getRecordMessage(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      fontSize: screenWidth * 0.05,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Expanded(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _currentOperationIndex + 1,
                  itemBuilder: (context, index) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${widget.operationsHistory[index]['question']} = ${widget.operationsHistory[index]['answer']} ${widget.operationsHistory[index]['isCorrect'] ? "✅" : "❌"}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: operationFontSize,
                          color: widget.operationsHistory[index]['isCorrect']
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bouton "Retour" placé à 1 cm du bas de l'écran
              SizedBox(height: screenHeight * 0.01),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, // Couleur d'arrière-plan
                  foregroundColor: Colors.black, // Couleur du texte
                  textStyle: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Retour'),
              ),
              SizedBox(height: screenHeight * 0.01),
            ],
          ),
        ),
      ),
    );
  }

  String _getRecordMessage() {
    if (widget.initialRecord == 0) {
      return "🎮 Première Partie !\nBienvenue dans l'aventure ! Vous venez d'établir votre score de référence avec ${widget.score} points.";
    } else if (widget.score > widget.initialRecord) {
      int improvement = widget.score - widget.initialRecord;
      return "🎉 NOUVEAU RECORD ! 🎉\nINCROYABLE ! Vous avez pulvérisé votre record personnel de $improvement points !\nVotre nouveau record est de ${widget.score} points.";
    } else if (widget.score == widget.initialRecord) {
      return "Vous avez égalé votre record de ${widget.initialRecord} points !\nContinuez sur cette lancée !";
    } else {
      return "Votre score est de ${widget.score} points.\nVotre record personnel est toujours de ${widget.initialRecord} points.\nContinuez à vous entraîner pour l'améliorer !";
    }
  }
}

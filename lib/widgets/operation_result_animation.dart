import 'package:flutter/material.dart';

class OperationResultAnimation extends StatefulWidget {
  final List<Map<String, dynamic>> questionDetails;

  OperationResultAnimation({required this.questionDetails});

  @override
  _OperationResultAnimationState createState() =>
      _OperationResultAnimationState();
}

class _OperationResultAnimationState extends State<OperationResultAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialisation du contrôleur d'animation
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Lancement initial de l'animation
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Si l'animation est terminée, on passe à l'élément suivant
        if (_currentIndex < widget.questionDetails.length - 1) {
          setState(() {
            _currentIndex++;
          });
          _controller.reset();
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questionDetails.isEmpty) {
      return Center(
        child: Text(
          "Aucune question disponible.",
          style: TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      );
    }

    final currentQuestion = widget.questionDetails[_currentIndex];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0.0, (1 - _animation.value) * 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                color: currentQuestion['isCorrect'] ? Colors.green : Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question: ${currentQuestion['question']}",
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Votre Réponse: ${currentQuestion['userAnswer']}",
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        currentQuestion['isCorrect']
                            ? "Réponse Correcte !"
                            : "Réponse Incorrecte. La bonne réponse était: ${currentQuestion['correctAnswer']}",
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

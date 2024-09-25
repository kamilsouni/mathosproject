import 'package:flutter/material.dart';

class ArcadeConsole extends StatefulWidget {
  final String question;
  final List<String> choices;
  final Function(String) onAnswer;
  final bool? isCorrect;

  ArcadeConsole({
    required this.question,
    required this.choices,
    required this.onAnswer,
    this.isCorrect,
  });

  @override
  _ArcadeConsoleState createState() => _ArcadeConsoleState();
}

class _ArcadeConsoleState extends State<ArcadeConsole> with SingleTickerProviderStateMixin {
  String _displayedText = '';
  late AnimationController _controller;
  late Animation<Color?> _screenColorAnimation;

  @override
  void initState() {
    super.initState();
    _displayedText = widget.question;

    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialisation de l'animation des couleurs de l'écran
    _screenColorAnimation = ColorTween(
      begin: Color(0xFF9BBC0F), // Couleur d'écran par défaut
      end: Color(0xFF9BBC0F), // Même couleur par défaut
    ).animate(_controller);

    if (widget.isCorrect != null) {
      _updateScreenColor();
    }
  }

  @override
  void didUpdateWidget(ArcadeConsole oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.question != oldWidget.question) {
      setState(() {
        _displayedText = widget.question;
      });
      _controller.reset();
    }

    // Mettre à jour l'animation des couleurs quand une réponse est donnée
    if (widget.isCorrect != null) {
      _updateScreenColor();
    }
  }

  void _updateScreenColor() {
    _screenColorAnimation = ColorTween(
      begin: Color(0xFF9BBC0F), // Couleur par défaut de l'écran
      end: widget.isCorrect == null
          ? Color(0xFF9BBC0F) // Couleur par défaut quand il n'y a pas de réponse
          : widget.isCorrect! ? Colors.green : Colors.red, // Vert si correct, rouge si incorrect
    ).animate(_controller);

    // Redémarre l'animation de l'écran à chaque fois
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double consoleWidth = constraints.maxWidth * 0.8;
        final double consoleHeight = consoleWidth * 1.6;

        return CustomPaint(
          painter: GameBoyConsolePainter(

            screenColor: _screenColorAnimation.value ?? Color(0xFF9BBC0F), // Utilise l'animation de couleur
            isCorrect: widget.isCorrect,
          ),
          child: Container(
            width: consoleWidth,
            height: consoleHeight,
            child: Column(
              children: [
                SizedBox(height: consoleHeight * 0.1),
                _buildScreen(consoleWidth * 0.8, consoleHeight * 0.4),
                Expanded(child: _buildControls(consoleWidth, consoleHeight)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScreen(double width, double height) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(8),
      child: Center(
        child: Text(
          _displayedText,
          style: TextStyle(
            color: Color(0xFF0F380F),
            fontSize: height * 0.15,
            fontFamily: 'VT323',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildControls(double consoleWidth, double consoleHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.choices.map((choice) => _buildAnswerButton(choice, consoleWidth)).toList(),
        ),
        SizedBox(height: consoleHeight * 0.1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSmallButton(),
            SizedBox(width: 20),
            _buildSmallButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerButton(String choice, double consoleWidth) {
    double buttonSize = consoleWidth * 0.2;
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        child: Text(
          choice,
          style: TextStyle(fontSize: 32, color: Colors.white, fontFamily: 'VT323'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF9C2C9C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => widget.onAnswer(choice),
      ),
    );
  }

  Widget _buildSmallButton() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: Colors.black, width: 2),
      ),
    );
  }
}

class GameBoyConsolePainter extends CustomPainter {
  final Color screenColor;
  final bool? isCorrect;

  GameBoyConsolePainter({
    required this.screenColor,
    this.isCorrect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final borderWidth = size.width * 0.05;

    // Dessiner la console principale en blanc
    paint.color = Color(0xFFA4A9A8); // Un gris légèrement plus foncé pour la Gameboy classique
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Bordure noire et coins
    paint.color = Colors.black;
    final cornerSize = borderWidth;

    // Peindre les coins extérieurs avec la couleur violette
    paint.color = Color(0xFF564560);
    canvas.drawRect(Rect.fromLTWH(0, 0, cornerSize, cornerSize), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - cornerSize, 0, cornerSize, cornerSize), paint);
    canvas.drawRect(Rect.fromLTWH(0, size.height - cornerSize, cornerSize, cornerSize), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - cornerSize, size.height - cornerSize, cornerSize, cornerSize), paint);

    // Dessiner les bords noirs
    paint.color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, cornerSize, borderWidth, size.height - 2 * cornerSize), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - borderWidth, cornerSize, borderWidth, size.height - 2 * cornerSize), paint);
    canvas.drawRect(Rect.fromLTWH(cornerSize, 0, size.width - 2 * cornerSize, borderWidth), paint);
    canvas.drawRect(Rect.fromLTWH(cornerSize, size.height - borderWidth, size.width - 2 * cornerSize, borderWidth), paint);

    // Écran avec bordure grise
    final screenBorderRect = Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.8, size.height * 0.4);
    paint.color = Colors.grey[600]!;
    canvas.drawRect(screenBorderRect, paint);

    final screenRect = screenBorderRect.deflate(borderWidth); // Même épaisseur que la bordure extérieure

    // Gradient pour l'écran en fonction de isCorrect
    paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isCorrect == null
            ? [screenColor, screenColor] // Couleur par défaut si pas encore de réponse
            : isCorrect!
            ? [Colors.green[200]!, Colors.green[100]!] // Couleur verte si réponse correcte
            : [Colors.red[200]!, Colors.red[100]!] // Couleur rouge si réponse incorrecte
    ).createShader(screenRect);

    // Dessiner l'écran
    canvas.drawRect(screenRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


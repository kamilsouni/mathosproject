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
  late AnimationController _controller;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _glowAnimation = ColorTween(begin: Colors.transparent, end: Colors.transparent).animate(_controller);
  }

  @override
  void didUpdateWidget(ArcadeConsole oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCorrect != oldWidget.isCorrect) {
      _glowAnimation = ColorTween(
        begin: _glowAnimation.value,
        end: widget.isCorrect == null ? Colors.transparent :
        widget.isCorrect! ? Color(0xFF9BBC0F) : Color(0xFFBA4B32),
      ).animate(_controller);
      _controller.forward(from: 0.0);
    }
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
        final double consoleWidth = constraints.maxWidth * 0.8;  // Ajustement selon la largeur de l'écran
        final double consoleHeight = consoleWidth * 1.6;  // Ratio 10:16 pour la Gameboy

        return Padding(
          padding: EdgeInsets.all(10),
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: Container(
              width: consoleWidth,
              height: consoleHeight,
              decoration: BoxDecoration(
                color: Color(0xFFDFDFDF),
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(2), // Bordures moins arrondies pour un effet pixelisé
              ),
              child: Column(
                children: [
                  SizedBox(height: consoleHeight * 0.05),
                  _buildScreen(consoleWidth * 0.8),
                  Expanded(child: _buildControls()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScreen(double screenWidth) {
    return Container(
      width: screenWidth,
      height: screenWidth * 0.75,  // Ratio de l'écran
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFF9BBC0F),
        border: Border.all(color: Color(0xFF616161), width: 2),
        // Effet de texture en "carrés" pour simuler un pixel art minimal
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              color: _glowAnimation.value ?? Color(0xFF9BBC0F),
              child: Center(
                child: Text(
                  widget.question,
                  style: TextStyle(
                    color: Color(0xFF0F380F),
                    fontFamily: 'VT323',
                    fontSize: screenWidth * 0.11, // Taille augmentée pour un effet pixelisé
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildDirectionalPad(),
            _buildAnswerButtons(),
          ],
        ),
        _buildStartSelectButtons(),
      ],
    );
  }

  Widget _buildDirectionalPad() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFF303030),
        border: Border.all(color: Colors.black, width: 2),  // Bordures marquées pour effet pixel
      ),
      child: Icon(Icons.gamepad, color: Colors.grey[400], size: 50),
    );
  }

  Widget _buildAnswerButtons() {
    return Column(
      children: widget.choices.map((choice) =>
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1),
            child: ElevatedButton(
              child: Text(
                choice,
                style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'VT323'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9C2C9C),
                shape: CircleBorder(),
                padding: EdgeInsets.all(20),
                minimumSize: Size(60, 60),
                elevation: 0,  // Pas d'ombrage pour respecter l'effet pixelisé
                shadowColor: Colors.transparent,
              ),
              onPressed: () => widget.onAnswer(choice),
            ),
          )
      ).toList(),
    );
  }

  Widget _buildStartSelectButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['SELECT', 'START'].map((label) =>
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Color(0xFF5A5A5A),
                border: Border.all(color: Colors.black, width: 2),  // Effet pixel avec bordures nettes
              ),
              child: Center(
                child: Text(label, style: TextStyle(color: Colors.white, fontFamily: 'VT323', fontSize: 12)),
              ),
            ),
          )
      ).toList(),
    );
  }
}

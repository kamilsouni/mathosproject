import 'package:flutter/material.dart';

class PacManButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const PacManButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _PacManButtonState createState() => _PacManButtonState();
}

class _PacManButtonState extends State<PacManButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double buttonWidth = screenWidth * 0.8;
    double buttonHeight = screenHeight * 0.1;
    double fontSize = buttonHeight * 0.2;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.orange : Colors.yellow,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(100),
            bottomRight: Radius.circular(100),
          ),
          border: Border.all(
            color: Colors.black,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          )
              : Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PixelFont',
              fontSize: fontSize,
              color: Colors.black,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.white.withOpacity(0.5),
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
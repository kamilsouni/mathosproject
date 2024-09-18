// arcade_console.dart
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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _glowAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(ArcadeConsole oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCorrect != oldWidget.isCorrect) {
      if (widget.isCorrect != null) {
        _glowAnimation = ColorTween(
          begin: _glowAnimation.value,
          end: widget.isCorrect! ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ).animate(_controller);
        _controller.forward(from: 0.0);
      } else {
        _glowAnimation = ColorTween(
          begin: _glowAnimation.value,
          end: Colors.transparent,
        ).animate(_controller);
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 500,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _glowAnimation.value ?? Colors.transparent,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'VT323',
                        fontSize: 32,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            children: widget.choices.map((choice) {
              return ElevatedButton(
                child: Text(
                  choice,
                  style: TextStyle(fontSize: 24),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(24),
                ),
                onPressed: () => widget.onAnswer(choice),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
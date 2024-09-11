import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int duration;
  final VoidCallback onCountdownComplete;
  final TextStyle? textStyle;
  final Color progressColor; // Ajout de la couleur de progression
  final double height; // Ajout de la hauteur de la barre de progression

  CountdownTimer({
    required this.duration,
    required this.onCountdownComplete,
    this.textStyle,
    this.progressColor =
        Colors.blue, // Valeur par défaut de la couleur de progression
    this.height =
        4.0, // Valeur par défaut de la hauteur de la barre de progression
  });

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    _controller.reverse(from: 1.0);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onCountdownComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get timerString {
    Duration duration = _controller.duration! * _controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Container(
                height: widget.height,
                child: LinearProgressIndicator(
                  value: _controller.value,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.progressColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int duration;
  final VoidCallback onCountdownComplete;
  final TextStyle? textStyle;
  final Color progressColor;
  final double height;
  final Key? key; // Ajout de key dans les paramètres

  CountdownTimer({
    this.key, // Ajout ici
    required this.duration,
    required this.onCountdownComplete,
    this.textStyle,
    this.progressColor = Colors.blue,
    this.height = 20.0,
  }) : super(key: key); // Passer la clé au constructeur parent

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

// Rendre l'état public en le déclarant hors de la classe
class CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPaused = false;

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

  void pauseTimer() {
    if (!_isPaused) {
      _controller.stop();
      _isPaused = true;
    }
  }

  void resumeTimer() {
    if (_isPaused) {
      _controller.reverse(from: _controller.value);
      _isPaused = false;
    }
  }

  String get timerString {
    Duration duration = _controller.duration! * _controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final elapsedSegments = ((widget.duration - (_controller.value * widget.duration)) / (widget.duration / 20)).floor();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timerString,
                style: widget.textStyle ?? TextStyle(
                  fontSize: 24,
                  fontFamily: 'PixelFont',
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width - 32,
                height: widget.height + 4,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  children: List.generate(20, (index) {
                    final isRed = index < elapsedSegments;
                    return Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: widget.height,
                              color: isRed ? Colors.red : Color(0xFF02C200),
                            ),
                          ),
                          if (index < 19)
                            Container(
                              width: 1,
                              height: widget.height,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
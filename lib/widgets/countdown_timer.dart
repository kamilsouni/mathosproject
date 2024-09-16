import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int duration;
  final VoidCallback onCountdownComplete;
  final TextStyle? textStyle;
  final Color progressColor;
  final double height; // Cette propriété sera utilisée comme hauteur maximale

  CountdownTimer({
    required this.duration,
    required this.onCountdownComplete,
    this.textStyle,
    this.progressColor = Colors.blue,
    this.height = 20.0,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth - 32; // 16 pixels de marge de chaque côté
    final segmentWidth = (barWidth - 4 - 19) / 20; // -4 pour la bordure, -19 pour les séparateurs
    final segmentHeight = segmentWidth < widget.height ? segmentWidth : widget.height;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final elapsedSegments = ((widget.duration - (_controller.value * widget.duration)) / 3).floor();
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
                width: barWidth,
                height: segmentHeight + 4, // +4 pour la bordure
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  children: List.generate(20, (index) {
                    final isRed = index < elapsedSegments;
                    return Row(
                      children: [
                        Container(
                          width: segmentWidth,
                          height: segmentHeight,
                          color: isRed ? Colors.red : Colors.green,
                        ),
                        if (index < 19) Container(
                          width: 1,
                          height: segmentHeight,
                          color: Colors.white,
                        ),
                      ],
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
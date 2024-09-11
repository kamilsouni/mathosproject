import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class LevelIndicator extends StatefulWidget {
  final int currentLevel;
  final int maxLevel;

  LevelIndicator({required this.currentLevel, required this.maxLevel});

  @override
  _LevelIndicatorState createState() => _LevelIndicatorState();
}

class _LevelIndicatorState extends State<LevelIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _vibrationAnimation;
  int previousLevel = 0;
  bool isLevelUp = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
    _vibrationAnimation = Tween<double>(begin: 0.0, end: 5.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_controller);
  }

  @override
  void didUpdateWidget(LevelIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLevel != widget.currentLevel) {
      isLevelUp = widget.currentLevel > previousLevel;
      _controller.forward(from: 0.0);
      _triggerVibration(weak: isLevelUp);
      previousLevel = widget.currentLevel;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerVibration({required bool weak}) async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      if (weak) {
        Vibration.vibrate(duration: 100); // Vibration légère
      } else {
        Vibration.vibrate(pattern: [0, 500, 200, 500]); // Vibration plus forte
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boxSize = screenWidth * 0.08;

    List<Widget> levelBlocks = [];

    for (int i = 1; i <= widget.maxLevel; i++) {
      levelBlocks.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double offset =
            i == widget.currentLevel ? _vibrationAnimation.value : 0.0;
            return Transform.translate(
              offset: Offset(offset, 0),
              child: Container(
                width: boxSize,
                height: boxSize,
                margin: EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  color: i == widget.currentLevel
                      ? Colors.orange
                      : Colors.black.withOpacity(0.7),
                  border: Border.all(color: Colors.black),
                  boxShadow: [
                    if (i == widget.currentLevel)
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$i',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: boxSize * 0.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: levelBlocks,
      ),
    );
  }
}

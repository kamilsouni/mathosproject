import 'package:flutter/material.dart';
import 'package:mathosproject/sound_manager.dart';
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
    if (!SoundManager.isVibrationEnabled()) return;  // Ajout de cette vérification

    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      if (weak) {
        Vibration.vibrate(duration: 100);
      } else {
        Vibration.vibrate(pattern: [0, 500, 200, 500]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double totalWidth = screenWidth - 32;
    double boxSize = (totalWidth - (widget.maxLevel - 1) * 4) / widget.maxLevel;

    List<Widget> levelBlocks = [];

    for (int i = 1; i <= widget.maxLevel; i++) {
      levelBlocks.add(
        Container(
          width: boxSize,
          height: boxSize,
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: i <= widget.currentLevel ? Colors.yellow : Colors.grey[800],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  '$i',
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    color: i <= widget.currentLevel ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'NIVEAU ${widget.currentLevel}',
          style: TextStyle(
            fontFamily: 'PixelFont',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: levelBlocks,
        ),
      ],
    );
  }
}

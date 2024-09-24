import 'package:flutter/material.dart';

class RetroProgressBar extends StatelessWidget {
  final int currentValue;
  final int maxValue;
  final double height;
  final Color fillColor;
  final Color backgroundColor;

  RetroProgressBar({
    required this.currentValue,
    required this.maxValue,
    this.height = 20,
    this.fillColor = Colors.yellow,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        children: List.generate(maxValue, (index) {
          final isRed = index < currentValue;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isRed ? fillColor : backgroundColor,
                border: Border(
                  right: BorderSide(
                    color: Colors.white,
                    width: index < maxValue - 1 ? 1 : 0,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
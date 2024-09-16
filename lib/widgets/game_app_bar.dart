import 'package:flutter/material.dart';

class GameAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int points;
  final int lastChange;

  GameAppBar({required this.points, required this.lastChange});

  @override
  _GameAppBarState createState() => _GameAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(75);
}

class _GameAppBarState extends State<GameAppBar>
    with SingleTickerProviderStateMixin {
  late int _previousPoints;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showChange = false;

  @override
  void initState() {
    super.initState();
    _previousPoints = widget.points;
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void didUpdateWidget(GameAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points != oldWidget.points) {
      setState(() {
        _showChange = true;
      });
      _controller.forward().then((_) {
        _controller.reset();
        setState(() {
          _previousPoints = widget.points;
          _showChange = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = screenSize.height * 0.10;
    final fontSize = screenSize.width * 0.045; // Taille légèrement réduite
    final pointsFontSize = screenSize.width * 0.04; // Taille plus grande pour les points
    final iconSize = screenSize.width * 0.08;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight + statusBarHeight),
      child: Container(
        color: Colors.yellow, // Jaune Pac-Man pour le fond
        child: SafeArea(
          child: Container(
            height: appBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_left,
                    color: Colors.black,
                    size: iconSize,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_showChange && widget.lastChange != 0)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            '${widget.lastChange > 0 ? "+" : ""}${widget.lastChange}',
                            style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: widget.lastChange > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        'Points:',
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: fontSize, // Taille de texte réduite
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Text(
                        '${widget.points}',
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: pointsFontSize, // Taille de texte des points
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

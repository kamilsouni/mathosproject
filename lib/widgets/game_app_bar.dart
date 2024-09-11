import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.7), // Fond semi-transparent
      elevation: 0, // Enlever l'ombre de l'AppBar
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            size: screenWidth * 0.09, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_showChange && widget.lastChange != 0)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                '${widget.lastChange > 0 ? "+" : ""}${widget.lastChange}',
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: widget.lastChange > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          SizedBox(
              width: screenWidth *
                  0.02), // Espace entre le changement de points et "Points:"
          Text(
            'Points:',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
              width: screenWidth *
                  0.02), // Espace entre "Points:" et le nombre de points
          Text(
            '${widget.points}',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }
}

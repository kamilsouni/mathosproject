import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  TopAppBar({required this.title, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = screenSize.height * 0.10;
    final fontSize = screenSize.width * 0.05;
    final iconSize = screenSize.width * 0.08;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight + statusBarHeight),
      child: Container(
        color: Colors.yellow,
        child: SafeArea(
          child: Container(
            height: appBarHeight,
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_left,
                      color: Colors.black,
                      size: iconSize,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context); // Retour à la page précédente si possible
                      } else {
                        Navigator.pushReplacementNamed(context, '/'); // Retour à la Home si impossible
                      }
                    },
                  ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                if (showBackButton)
                  SizedBox(width: iconSize), // Pour équilibrer l'espace avec le bouton retour
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

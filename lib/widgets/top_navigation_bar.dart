import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/profile_detail_screen.dart';
import 'package:mathosproject/screens/settings_screen.dart';
import 'package:mathosproject/screens/stats_screen.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Function? onBackPressed;

  TopAppBar({
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
  });

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
                      if (onBackPressed != null) {
                        onBackPressed!();
                        return;
                      }

                      String? currentRoute = ModalRoute.of(context)?.settings.name;
                      Widget? currentWidget = context.widget;
                      AppUser? profile;

                      // Récupérer le profil en fonction de l'écran actuel
                      if (currentWidget is StatsScreen) {
                        profile = (currentWidget).profile;
                      } else if (currentWidget is ProfileDetailScreen) {
                        profile = (currentWidget).profile;
                      } else if (currentWidget is SettingsScreen) {
                        profile = (currentWidget).profile;
                      }

                      // Si on a un profil et qu'on est sur un des écrans spéciaux
                      if (profile != null && (
                          currentRoute?.contains('statsscreen') == true ||
                              currentRoute?.contains('profiledetailscreen') == true ||
                              currentRoute?.contains('settingsscreen') == true)) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModeSelectionScreen(profile: profile!),
                            settings: RouteSettings(name: '/modeselectionscreen'),
                          ),
                        );
                      } else {
                        // Comportement par défaut pour les autres écrans
                        Navigator.maybePop(context);
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
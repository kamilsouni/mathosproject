import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/stats_screen.dart';
import 'package:mathosproject/screens/profile_detail_screen.dart';
import 'package:mathosproject/screens/settings_screen.dart';
import 'package:mathosproject/sound_manager.dart';  // Import the SoundManager

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final AppUser profile;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF564560),
        border: Border(
          top: BorderSide(
            color: Colors.yellow,
            width: 3,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0, 'JOUER', Image.asset('assets/jouer.png')),
            _buildNavItem(context, 1, 'STATS', Image.asset('assets/stats.png')),
            _buildNavItem(context, 2, 'PROFIL', Image.asset('assets/users.png')),
            _buildNavItem(context, 3, 'OPTIONS', Image.asset('assets/settings.png')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String label, Widget icon) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          await SoundManager.playButtonClickSound(); // Play sound when item is selected
          onTap(index);
          _navigateToScreen(context, index);
        },
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFFFF00) : Colors.transparent,
            border: Border(
              top: BorderSide(
                color: isSelected ? Color(0xFFFFFF00) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: icon,  // Utilise Flexible pour permettre à l'icône de s'adapter
              ),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Color(0xFFFFFFFF),
                  fontSize: 10,
                  fontFamily: 'PixelFont',
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: profile)));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StatsScreen(profile: profile)));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileDetailScreen(profile: profile)));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SettingsScreen(profile: profile)));
        break;
    }
  }
}

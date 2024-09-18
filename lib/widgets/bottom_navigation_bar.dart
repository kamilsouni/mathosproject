import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/stats_screen.dart';
import 'package:mathosproject/screens/profile_detail_screen.dart';
import 'package:mathosproject/screens/settings_screen.dart';

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
        color: Color(0xFF000000),
        border: Border(
          top: BorderSide(
            color: Color(0xFFFFFF00),
            width: 3,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0, 'JOUER', '▶️'),
            _buildNavItem(context, 1, 'STATS', '📊'),
            _buildNavItem(context, 2, 'PROFIL', '👤'),
            _buildNavItem(context, 3, 'OPTIONS', '⚙️'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String label, String icon) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTap(index);
          _navigateToScreen(context, index);
        },
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF4A4A4A) : Colors.transparent,
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
              Text(
                icon,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Color(0xFFFFFF00) : Color(0xFFFFFFFF),
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
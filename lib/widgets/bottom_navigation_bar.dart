import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/profile_detail_screen.dart';
import 'package:mathosproject/screens/stats_screen.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
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
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Color(0xFFFFFF00),
            width: 3,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        items: [
          _buildNavItem('Jouer'),
          _buildNavItem('Stats'),
          _buildNavItem('Profil'),
          _buildNavItem('Options'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Color(0xFFFFFF00),
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedLabelStyle: TextStyle(
          fontFamily: 'PixelFont',
          fontSize: 16,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'PixelFont',
          fontSize: 14,
        ),
        onTap: (index) {
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
          onTap(index);
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String label) {
    return BottomNavigationBarItem(
      icon: SizedBox.shrink(), // Pas d'icône
      label: label,
    );
  }
}
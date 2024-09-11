import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/profile_detail_screen.dart';
import 'package:mathosproject/screens/stats_screen.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';

class SettingsScreen extends StatelessWidget {
  final AppUser profile;

  SettingsScreen({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Paramètres'),
      body: Center(
        child: Text(
          'EN CONSTRUCTION',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3, // Paramètres est sélectionné
        profile: profile,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ModeSelectionScreen(profile: profile)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => StatsScreen(profile: profile)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileDetailScreen(profile: profile)),
              );
              break;
            case 3:
            // Do nothing because we are already on the Settings screen
              break;
          }
        },
      ),
    );
  }
}
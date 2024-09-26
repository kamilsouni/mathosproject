import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/profile_detail_screen.dart';
import 'package:mathosproject/screens/stats_screen.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  final AppUser profile;

  SettingsScreen({required this.profile});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEffectsEnabled = true;
  bool _backgroundMusicEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: TopAppBar(title: 'Infos & Paramètres', showBackButton: true),
      body: Container(
        color: Color(0xFF564560),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12), // Réduction du padding général
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.02), // Espacement supérieur pour mieux respirer
                _buildSection('Règles du jeu', [
                  _buildSubsection('Modes de jeu', () {}),
                  _buildSubsection('Système de points', () {}),
                ]),
                _buildSection('Paramètres', [
                  _buildToggleSubsection('Effets sonores', _soundEffectsEnabled, (value) {
                    setState(() => _soundEffectsEnabled = value);
                  }),
                  _buildToggleSubsection('Musique', _backgroundMusicEnabled, (value) {
                    setState(() => _backgroundMusicEnabled = value);
                  }),
                  _buildToggleSubsection('Notifications', _notificationsEnabled, (value) {
                    setState(() => _notificationsEnabled = value);
                  }),
                ]),
                _buildSection('Compte', [
                  _buildSubsection('Modifier profil', () {}),
                  _buildSubsection('Mot de passe', () {}),
                ]),
                _buildSection('Confidentialité', [
                  _buildSubsection('Politique', () {}),
                  _buildSubsection('Conditions', () {}),
                ]),
                _buildSection('À propos', [
                  _buildSubsection('Développeurs', () {}),
                  _buildSubsection('Version', () {}),
                ]),
                _buildSection('Mode hors-ligne', [
                  _buildSubsection('Fonctionnement', () {}),
                ]),
                SizedBox(height: screenHeight * 0.02), // Espacement inférieur
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3,
        profile: widget.profile,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: widget.profile)));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StatsScreen(profile: widget.profile)));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileDetailScreen(profile: widget.profile)));
              break;
            case 3:
            // Déjà sur l'écran des paramètres
              break;
          }
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 16, // Taille plus uniforme
            fontFamily: 'PixelFont',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8), // Espace standard entre titre et éléments
        Column(
          children: children.map((child) {
            return Container(
              height: 50, // Définir une hauteur fixe pour uniformiser la taille des blocs
              child: child,
            );
          }).toList(),
        ),
        SizedBox(height: 16), // Espacement standard entre les sections
      ],
    );
  }

  Widget _buildSubsection(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.yellow, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 12),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.yellow, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSubsection(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 12),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.yellow,
            inactiveThumbColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/profile_detail_screen.dart';
import 'package:mathosproject/screens/stats_screen.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:mathosproject/sound_manager.dart';
import 'package:mathosproject/utils/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ajout pour gérer la persistance

class SettingsScreen extends StatefulWidget {
  final AppUser profile;

  SettingsScreen({required this.profile});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEffectsEnabled = SoundManager.isSoundEnabled();
  bool _backgroundMusicEnabled = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Charger les paramètres sauvegardés
  }

  // Fonction pour charger les préférences sauvegardées
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true; // Notifications par défaut activées
    });
  }

  // Fonction pour sauvegarder les préférences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: TopAppBar(title: 'Infos & Paramètres', showBackButton: true),
      body: Container(
        color: Color(0xFF564560),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.02),
                _buildSection('Règles du jeu', [
                  _buildSubsection('Modes de jeu', _showGameModesDialog),
                  _buildSubsection('Système de points', _showScoringSystemDialog),
                ]),
                _buildSection('Paramètres', [
                  _buildToggleSubsection('Effets sonores', _soundEffectsEnabled, (value) {
                    setState(() {
                      _soundEffectsEnabled = value;
                      SoundManager.setSoundEnabled(value);
                    });
                  }),
                  _buildToggleSubsection('Musique', _backgroundMusicEnabled, (value) {
                    setState(() => _backgroundMusicEnabled = value);
                  }),
                  _buildToggleSubsection('Notifications', _notificationsEnabled, (value) {
                    setState(() {
                      _notificationsEnabled = value;
                      if (_notificationsEnabled) {
                        NotificationService.scheduleDailyNotification();
                      } else {
                        NotificationService.cancelAllNotifications();
                      }
                      _saveSettings(); // Sauvegarde l'état des notifications
                    });
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
                SizedBox(height: screenHeight * 0.02),
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
            fontSize: 16,
            fontFamily: 'PixelFont',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Column(
          children: children.map((child) {
            return Container(
              height: 50,
              child: child,
            );
          }).toList(),
        ),
        SizedBox(height: 16),
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


  // Dialog to show game modes
  void _showGameModesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF564560),
          title: Text(
            "Modes de jeu",
            style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont', fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("1. Mode Rapidité : Enchaîne les bonnes réponses en 60 secondes chrono pour faire grimper ton score en flèche."),
                SizedBox(height: 10),
                Text("2. Mode Problème : Deux minutes pour résoudre des problèmes de calcul. Chaque bonne réponse te fait monter d'un niveau."),
                SizedBox(height: 10),
                Text("3. Mode Équations : Trouve la pièce manquante dans l'équation pour avancer. Attention, 60 secondes seulement !"),
                SizedBox(height: 10),
                Text("4. Mode Progression : Enchaîne additions, soustractions, multiplications et divisions pour débloquer des astuces et grimper de niveau."),
                SizedBox(height: 10),
                Text("5. Mode Compétition : Affronte les autres joueurs pour prouver qui est le meilleur. Vise le sommet du classement !"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer', style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont')),
            ),
          ],
        );
      },
    );
  }

  // Dialog to show scoring system
  void _showScoringSystemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF564560),
          title: Text(
            "Système de points",
            style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont', fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoringSystemText('Mode Rapidité', [
                  'Réponses correctes : 10 points par réponse, multipliés par le niveau actuel.',
                  'Multiplicateur de rapidité : +50 points après plusieurs bonnes réponses.',
                  'Passer la question : -100 points et perte d\'un niveau.',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Problème', [
                  'Réponses correctes : 50 points par réponse, multipliés par le niveau.',
                  'Bonus : +50 points pour 3 bonnes réponses consécutives.',
                  'Passer la question : -100 points et perte d\'un niveau.',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Équations', [
                  'Réponses correctes : 10 points par réponse, multipliés par le niveau actuel.',
                  'Bonus : +100 points à chaque niveau terminé.',
                  'Mauvaise réponse : -5 points et perte d\'un niveau.',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Progression', [
                  'Réponses correctes : 10 points par réponse, multipliés par le niveau.',
                  'Bonus de niveau : +100 points pour chaque niveau terminé.',
                  'Passer la question : -100 points.',
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer', style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoringSystemText(String mode, List<String> pointsInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mode,
          style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont', fontSize: 14),
        ),
        SizedBox(height: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pointsInfo.map((info) {
            return Text(
              info,
              style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 12),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

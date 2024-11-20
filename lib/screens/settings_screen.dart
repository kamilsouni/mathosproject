import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _notificationsEnabled = true;


  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.yellow,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
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
    final Size screenSize = MediaQuery.of(context).size;
    final double verticalSpacing = screenSize.height * 0.015;
    final double horizontalPadding = screenSize.width * 0.04;

    return Scaffold(
      appBar: TopAppBar(
        title: 'Infos & Paramètres',
        showBackButton: true,
        onBackPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ModeSelectionScreen(profile: widget.profile),
            ),
          );
        },
      ),
      body: Container(
        color: Color(0xFF564560),
        height: screenSize.height, // Force le conteneur à prendre toute la hauteur
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: verticalSpacing),
                _buildSection('Règles du jeu', [
                  _buildSubsection('Modes de jeu', _showGameModesDialog, screenSize),
                  _buildSubsection('Système de points', _showScoringSystemDialog, screenSize),
                ], screenSize),
                _buildSection('Paramètres', [
                  _buildToggleSubsection(
                    'Effets sonores',
                    _soundEffectsEnabled,
                        (value) {
                      setState(() {
                        _soundEffectsEnabled = value;
                        SoundManager.setSoundEnabled(value);
                      });
                    },
                    screenSize,
                  ),
                  _buildToggleSubsection(
                    'Notifications',
                    _notificationsEnabled,
                        (value) {
                      setState(() {
                        _notificationsEnabled = value;
                        if (_notificationsEnabled) {
                          NotificationService.scheduleDailyNotification();
                        } else {
                          NotificationService.cancelAllNotifications();
                        }
                        _saveSettings();
                      });
                    },
                    screenSize,
                  ),
                ], screenSize),
                _buildSection('Confidentialité', [
                  _buildSubsection('Politique', () {
                    _showDialog('Politique', 'Vos données personnelles sont synchronisées et stockées via Firebase et Hive. Elles sont utilisées uniquement pour améliorer votre expérience de jeu et ne seront jamais partagées avec des tiers.', screenSize);
                  }, screenSize),
                  _buildSubsection('Conditions', () {
                    _showDialog('Conditions', 'En utilisant cette application, vous acceptez de respecter les règles du jeu et de ne pas utiliser de méthodes non autorisées pour améliorer votre score.', screenSize);
                  }, screenSize),
                ], screenSize),
                _buildSection('À propos', [
                  _buildSubsection('Développeurs', () {
                    _showDialog('Développeurs', 'Cette application a été conçue avec amour, café et... quelques assistants IA. Si vous trouvez un bug, dites-vous que même les IA ne sont pas parfaites (mais elles s\'en approchent). Merci aux robots qui nous aident à calculer plus vite que jamais !', screenSize);
                  }, screenSize),
                  _buildSubsection('Version', () {
                    _showDialog('Version', '1.0', screenSize);
                  }, screenSize),
                ], screenSize),
                _buildSection('Mode hors-ligne', [
                  _buildSubsection('Fonctionnement', () {
                    _showDialog('Fonctionnement hors-ligne', 'Tout est accessible hors ligne sauf le mode compétition. Si une compétition est en cours avec une connexion instable, celle-ci fonctionne en mode dégradé.', screenSize);
                  }, screenSize),
                ], screenSize),
                SizedBox(height: verticalSpacing * 2),
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

  Widget _buildSection(String title, List<Widget> children, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.yellow,
            fontSize: screenSize.height * 0.02,
            fontFamily: 'PixelFont',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenSize.height * 0.008),
        ...children,
        SizedBox(height: screenSize.height * 0.005),
      ],
    );
  }


  Widget _buildSubsection(String title, VoidCallback onTap, Size screenSize) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenSize.height * 0.06,
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.015,
          horizontal: screenSize.width * 0.04,
        ),
        margin: EdgeInsets.only(bottom: screenSize.height * 0.01),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenSize.width * 0.02),
          border: Border.all(color: Colors.yellow, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PixelFont',
                  fontSize: screenSize.height * 0.015,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.yellow, size: screenSize.height * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSubsection(String title, bool value, Function(bool) onChanged, Size screenSize) {
    return Container(
      height: screenSize.height * 0.08,
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.015,
        horizontal: screenSize.width * 0.04,
      ),
      margin: EdgeInsets.only(bottom: screenSize.height * 0.01),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenSize.width * 0.02),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PixelFont',
                fontSize: screenSize.height * 0.015,
              ),
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

  void _showDialog(String title, String content, Size screenSize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF564560),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.yellow,
              fontFamily: 'PixelFont',
              fontSize: screenSize.height * 0.025,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'PixelFont',
              fontSize: screenSize.height * 0.02,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fermer',
                style: TextStyle(
                  color: Colors.yellow,
                  fontFamily: 'PixelFont',
                  fontSize: screenSize.height * 0.02,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                _buildScoringSystemText('Mode Rapidité', [
                  'Réponds correctement en 60 secondes pour faire exploser ton score. Trois réponses justes de suite te font monter de niveau, tandis que passer une question te fait descendre. Chaque niveau apporte des questions de plus en plus difficiles.',
                  'La vitesse est ta meilleure alliée ! Plus tu réponds rapidement, plus tu gagnes de points bonus. Fais attention, chaque hésitation te coûte du temps précieux.',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Problème', [
                  'Tu as deux minutes pour résoudre un maximum de problèmes. Trois réponses consécutives réussies te font monter d\'un niveau, avec des questions de plus en plus complexes.',
                  'Ce mode est parfait pour tester ton raisonnement sous pression. Garde en tête qu\'une seule erreur peut te coûter des points précieux !',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Équations', [
                  'Trouve la pièce manquante dans l\'équation. Parfois, c\'est un chiffre, parfois un signe mathématique. Trois bonnes réponses d\'affilée te font monter de niveau, mais passer une question te fait redescendre.',
                  'Tu n\'as que 60 secondes pour résoudre le maximum d\'équations. Chaque seconde compte, et chaque erreur te fait reculer dans le classement. Reste concentré et avance à toute vitesse !',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Progression', [
                  'Enchaîne les additions, soustractions, multiplications et divisions pour débloquer des astuces et grimper de niveau.',
                  'Pour passer au niveau suivant, tu dois valider tous les opérateurs (addition, soustraction, etc.), puis terminer par des calculs mixtes. Chaque niveau te débloque une astuce qui te rendra plus fort en calcul mental.',
                  'Ce mode est idéal pour ceux qui veulent progresser pas à pas. Tu dois remplir une jauge de bonnes réponses, visible en haut de l\'écran, pour valider une épreuve et passer au niveau suivant.',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Compétition', [
                  'Affronte tes amis pour prouver qui est le meilleur. Tu peux choisir combien de parties de chaque type tu veux inclure dans la compétition.',
                  'Prends les commandes du classement en affrontant les autres joueurs en temps réel. Sauras-tu atteindre le sommet et dominer la compétition ?',
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

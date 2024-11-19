import 'package:flutter/material.dart';
import 'package:mathosproject/dialog_manager.dart';
import 'package:mathosproject/models/app_user.dart'; // Import AppUser
import 'package:mathosproject/screens/progression_screen.dart';
import 'package:mathosproject/screens/reward_mode_screen.dart'; // Importer l'écran de récompense
import 'package:mathosproject/sound_manager.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';

class ProgressionModeScreen extends StatefulWidget {
  final AppUser profile;

  ProgressionModeScreen({required this.profile});

  @override
  _ProgressionModeScreenState createState() => _ProgressionModeScreenState();
}

class _ProgressionModeScreenState extends State<ProgressionModeScreen> {
  int _selectedIndex = 0; // Index par défaut pour la barre de navigation
  Map<int, Map<String, bool>> _progress = {};

  @override
  void initState() {
    super.initState();
    // Initialiser la progression avec les valeurs par défaut
    for (int i = 1; i <= 10; i++) {
      _progress[i] = {
        'Addition': false,
        'Soustraction': false,
        'Multiplication': false,
        'Division': false,
        'Mixte': false,
      };
    }
    // Vérifier et mettre à jour l'accessibilité du mode mixte
    widget.profile.updateAccessibility();
    // Sauvegarder les modifications de l'utilisateur
    _saveProfile();
  }

  Future<void> _saveProfile() async {
    if (await ConnectivityManager().isConnected()) {
      await UserPreferences.updateProfileInFirestore(widget.profile);
    } else {
      await UserPreferences.saveProfileLocally(widget.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopAppBar(title: 'Mode Progression', showBackButton: true),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xFF564560), // Couleur de fond pour un effet rétro
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.9,
                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    for (int level = 1; level <= 10; level++) ...[
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        color: Colors.white.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.yellow, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text(
                                'Niveau $level',
                                style: TextStyle(
                                    fontFamily: 'PixelFont', // Utiliser une police pixel art
                                    fontSize: screenWidth * 0.04, // Taille adaptée au style rétro
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildOperationButton('Addition', level, screenWidth, screenHeight),
                                  _buildOperationButton('Soustraction', level, screenWidth, screenHeight),
                                  _buildOperationButton('Multiplication', level, screenWidth, screenHeight),
                                  _buildOperationButton('Division', level, screenWidth, screenHeight),
                                  _buildOperationButton('Mixte', level, screenWidth, screenHeight, isMixte: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        profile: widget.profile,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildOperationButton(String operation, int level, double screenWidth, double screenHeight, {bool isMixte = false}) {
    bool isAccessible = widget.profile.progression[level]?[operation]?['accessibility'] == 1;
    bool isValidated = widget.profile.progression[level]?[operation]?['validation'] == 1;

    Color buttonColor;
    if (!isAccessible) {
      buttonColor = Colors.red;
    } else if (isValidated) {
      buttonColor = Color(0xFF00FF00);
    } else {
      buttonColor = Colors.yellow.withOpacity(0.7);
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: isAccessible ? () async {
            // Play sound on button click
            await SoundManager.playButtonClickSound();
            startTest(operation, level);
          } : null,
          child: Text(
            _getOperationSymbol(operation),
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontFamily: 'PixelFont',
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }


  void calculateAndAddPointsProgression(AppUser user, int level, bool isCorrect) {
    int points = isCorrect ? 10 * level : -10; // 10 points par niveau pour les bonnes réponses, -10 points pour les mauvaises réponses
    user.points += points;
  }

  String _getOperationSymbol(String operation) {
    switch (operation) {
      case 'Addition':
        return '+';
      case 'Soustraction':
        return '-';
      case 'Multiplication':
        return '×';
      case 'Division':
        return '÷';
      case 'Mixte':
        return '+-×÷';
      default:
        return '';
    }
  }

  void startTest(String operation, int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressionScreen(
          mode: operation,
          level: level,
          duration: 60,
          profile: widget.profile,
          isInitialTest: false,
          isCompetition: false,
        ),
      ),
    ).then((result) async {
      if (result != null && result == true) {
        setState(() {
          bool isLevelFullyValidated = widget.profile.validateOperator(level, operation);
          calculateAndAddPointsProgression(widget.profile, level, true); // Add points for successful validation
          _saveProfile(); // Sauvegarder les modifications du profil

          if (isLevelFullyValidated) {
            _showLevelUnlockedMessage();
          } else {
            _showNewTipMessage();
          }
        });
      }
    });
  }

  void _showLevelUnlockedMessage() {
    // Utilisation du DialogManager pour afficher le message de niveau débloqué
    DialogManager.showCustomDialog(
      context: context,
      title: 'Niveau débloqué!',  // Titre du dialogue
      content: 'Vous avez débloqué le niveau suivant.',  // Contenu du message
      confirmText: 'OK',  // Texte du bouton de confirmation
      onConfirm: () {
        Navigator.of(context).pop();  // Fermer le dialogue
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProgressionModeScreen(profile: widget.profile),  // Naviguer vers l'écran de progression
          ),
        );
      }, buttonColor: Colors.green,
    );
  }


  void _showNewTipMessage() {
    // Utilisation du DialogManager pour afficher le message d'astuce débloquée
    DialogManager.showCustomDialog(
      context: context,
      title: 'Nouvelle Astuce Disponible!',  // Titre du dialogue
      content: 'Une nouvelle astuce est disponible.',  // Contenu du message
      confirmText: 'OK',  // Texte du bouton de confirmation
      onConfirm: () {
        Navigator.of(context).pop();  // Fermer le dialogue
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RewardModeScreen(profile: widget.profile),  // Naviguer vers l'écran de récompense
          ),
        );
      }, buttonColor: Colors.green,
    );
  }


}

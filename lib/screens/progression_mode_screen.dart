import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/models/app_user.dart'; // Import AppUser
import 'package:mathosproject/screens/progression_screen.dart';
import 'package:mathosproject/screens/reward_mode_screen.dart'; // Importer l'écran de récompense
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
      appBar: TopAppBar(title: 'Mode Progression'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: SvgPicture.asset(
                'assets/fond_d_ecran.svg',
                fit: BoxFit.cover,
              ),
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
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.black, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text(
                                'Niveau $level',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
      buttonColor = Colors.grey;
    } else if (isValidated) {
      buttonColor = Colors.green;
    } else {
      buttonColor = Colors.black.withOpacity(0.7);
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: isAccessible ? () => startTest(operation, level) : null,
          child: Text(
            _getOperationSymbol(operation),
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
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
        builder: (context) => MentalMathTestScreen(
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Niveau débloqué!'),
          content: Text('Vous avez débloqué le niveau suivant.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressionModeScreen(profile: widget.profile),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showNewTipMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nouvelle Astuce Disponible!'),
          content: Text('Une nouvelle astuce est disponible dans le mode récompense.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RewardModeScreen(profile: widget.profile), // Naviguer vers l'écran de récompense
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

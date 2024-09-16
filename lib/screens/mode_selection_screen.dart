import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/precision_mode_screen.dart';
import 'package:mathosproject/screens/progression_mode_screen.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';
import 'package:mathosproject/screens/equations_mode_screen.dart';
import 'package:mathosproject/screens/join_or_create_competition_screen.dart';
import 'package:mathosproject/screens/reward_mode_screen.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';

class ModeSelectionScreen extends StatefulWidget {
  final AppUser profile;

  ModeSelectionScreen({required this.profile});

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int _selectedIndex = 0;

  final Map<String, String> modeDescriptions = {
    'Mode Progression': 'Dans ce mode de jeu, il y a 10 niveaux avec des exercices pour chaque opérateur et un mode mixte. Validez les 4 opérateurs et le mode mixte pour passer au niveau suivant.',
    'Mode Rapidité': 'Répondez à autant de questions que possible en 1 minute. La difficulté augmente avec chaque réponse correcte. Des points sont attribués pour chaque réponse correcte.',
    'Mode Précision': 'Les calculs sont très difficiles dans ce mode. Essayez de vous rapprocher le plus possible du résultat exact pour gagner plus de points.',
    'Mode Équations': 'Résolvez des équations à trou en fonction de votre niveau. Trouvez la bonne réponse pour progresser. Plus vous répondez correctement, plus la difficulté augmente.',
    'Astuces': 'Débloquez des astuces pour chaque niveau réussi dans le mode progression.',
    'Competition': 'Défiez d\'autres utilisateurs dans des compétitions de calcul mental.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopAppBar(title: 'Sélection du mode', showBackButton: true),
      body: Container(
        // Remplacement par le fond uni rétro
        decoration: BoxDecoration(
          color: Color(0xFF564560), // Couleur de fond rétro
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(16),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildModeButton(
                      title: 'Mode Progression',
                      icon: 'assets/icons/progression_icon.png',
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressionModeScreen(profile: widget.profile))),
                    ),
                    _buildModeButton(
                      title: 'Astuces',
                      icon: 'assets/icons/tips_icon.png',
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RewardModeScreen(profile: widget.profile))),
                    ),
                    _buildModeButton(
                      title: 'Mode Rapidité',
                      icon: 'assets/icons/speed_icon.png',
                      onPressed: () => _showStartConfirmation(context, 'Mode Rapidité', () => Navigator.push(context, MaterialPageRoute(builder: (context) => RapidityModeScreen(profile: widget.profile)))),
                    ),
                    _buildModeButton(
                      title: 'Mode Précision',
                      icon: 'assets/icons/precision_icon.png',
                      onPressed: () => _showStartConfirmation(context, 'Mode Précision', () => Navigator.push(context, MaterialPageRoute(builder: (context) => PrecisionModeScreen(profile: widget.profile)))),
                    ),
                    _buildModeButton(
                      title: 'Mode Équations',
                      icon: 'assets/icons/equations_icon.png',
                      onPressed: () => _showStartConfirmation(context, 'Mode Équations', () => Navigator.push(context, MaterialPageRoute(builder: (context) => EquationsModeScreen(profile: widget.profile)))),
                    ),
                    _buildModeButton(
                      title: 'Competition',
                      icon: 'assets/icons/competition_icon.png',
                      onPressed: () async {
                        bool isConnected = await ConnectivityManager().isConnected();
                        if (isConnected) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => JoinOrCreateCompetitionScreen(profile: widget.profile)));
                        } else {
                          _showNoConnectionDialog(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildModeButton({
    required String title,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: () => _showDescriptionDialog(context, title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Color(0xFFFFFF00),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFFF00).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 64,
              height: 64,
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 16,
                color: Color(0xFFFFFF00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDescriptionDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF000000),
          title: Text(
            title,
            style: TextStyle(color: Color(0xFFFFFF00), fontFamily: 'PixelFont'),
          ),
          content: Text(
            modeDescriptions[title] ?? 'Description non disponible.',
            style: TextStyle(color: Colors.white, fontFamily: 'PixelFont'),
          ),
          actions: [
            TextButton(
              child: Text(
                'Fermer',
                style: TextStyle(color: Color(0xFFFFFF00), fontFamily: 'PixelFont'),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showStartConfirmation(
      BuildContext context, String mode, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('La partie va commencer'),
          content: Text(
            "Installe-toi confortablement... La partie ne dure qu'une minute, on y va?",
            style: TextStyle(fontSize: 16.0),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Commencer'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pas de connexion Internet'),
          content: Text(
              'Vous devez être connecté à Internet pour accéder à ce mode.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

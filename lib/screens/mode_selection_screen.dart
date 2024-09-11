import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/precision_mode_screen.dart';
import 'package:mathosproject/screens/progression_mode_screen.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';
import 'package:mathosproject/screens/equations_mode_screen.dart'; // Import du nouvel écran
import 'package:mathosproject/screens/join_or_create_competition_screen.dart';
import 'package:mathosproject/screens/reward_mode_screen.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:mathosproject/utils/connectivity_manager.dart'; // Import de la gestion de la connectivité

class ModeSelectionScreen extends StatefulWidget {
  final AppUser profile;

  ModeSelectionScreen({required this.profile});

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int _selectedIndex = 0; // Index par défaut pour la barre de navigation

  final Map<String, String> modeDescriptions = {
    'Mode Progression':
    'Dans ce mode de jeu, il y a 10 niveaux avec des exercices pour chaque opérateur et un mode mixte. Validez les 4 opérateurs et le mode mixte pour passer au niveau suivant.',
    'Mode Rapidité':
    'Répondez à autant de questions que possible en 1 minute. La difficulté augmente avec chaque réponse correcte. Des points sont attribués pour chaque réponse correcte.',
    'Mode Précision':
    'Les calculs sont très difficiles dans ce mode. Essayez de vous rapprocher le plus possible du résultat exact pour gagner plus de points.',
    'Mode Équations':
    'Résolvez des équations à trou en fonction de votre niveau. Trouvez la bonne réponse pour progresser. Plus vous répondez correctement, plus la difficulté augmente.',
    'Astuces':
    'Débloquez des astuces pour chaque niveau réussi dans le mode progression.',
    'Mode Challenge':
    'Défiez d\'autres utilisateurs dans des compétitions de calcul mental.',
  };

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: 'Sélection du mode'),
      body: Center(
        child: Stack(
          alignment: Alignment.center, // Centrer le contenu dans le Stack
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
            GridView.count(
              crossAxisCount: 2, // Nombre de colonnes dans la grille
              padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical:
                  screenHeight * 0.2), // Ajuster l'espacement vertical
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildModeButton(
                  title: 'Mode Progression',
                  icon: Icons.trending_up,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProgressionModeScreen(profile: widget.profile),
                      ),
                    );
                  },
                ),
                _buildModeButton(
                  title: 'Astuces',
                  icon: Icons.star,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RewardModeScreen(profile: widget.profile),
                      ),
                    );
                  },
                ),
                _buildModeButton(
                  title: 'Mode Rapidité',
                  icon: Icons.timer,
                  onPressed: () {
                    _showStartConfirmation(context, 'Mode Rapidité', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RapidityModeScreen(profile: widget.profile),
                        ),
                      );
                    });
                  },
                ),
                _buildModeButton(
                  title: 'Mode Précision',
                  icon: Icons.calculate,
                  onPressed: () {
                    _showStartConfirmation(context, 'Mode Précision', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PrecisionModeScreen(profile: widget.profile),
                        ),
                      );
                    });
                  },
                ),
                _buildModeButton(
                  title: 'Mode Équations', // Remplacement de "Défis Quotidiens"
                  icon: Icons.functions,
                  onPressed: () {
                    _showStartConfirmation(context, 'Mode Équations', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EquationsModeScreen(profile: widget.profile),
                        ),
                      );
                    });
                  },
                ),
                _buildModeButton(
                  title: 'Mode Challenge',
                  icon: Icons.gamepad_sharp,
                  onPressed: () async {
                    bool isConnected = await ConnectivityManager().isConnected();
                    if (isConnected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JoinOrCreateCompetitionScreen(
                              profile: widget.profile),
                        ),
                      );
                    } else {
                      _showNoConnectionDialog(context);
                    }
                  },
                ),
              ],
            ),
          ],
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
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    Color buttonColor =
    onPressed != null ? Colors.black.withOpacity(0.7) : Colors.grey;

    return Tooltip(
      message: modeDescriptions[title] ?? '',
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onPressed,
          onLongPress: () {
            _showDescriptionDialog(context, title);
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDescriptionDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content:
          Text(modeDescriptions[title] ?? 'Description non disponible.'),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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

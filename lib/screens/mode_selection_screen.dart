import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/join_or_create_competition_screen.dart';
import 'package:mathosproject/screens/progression_mode_screen.dart';
import 'package:mathosproject/screens/reward_mode_screen.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';
import 'package:mathosproject/screens/precision_mode_screen.dart';
import 'package:mathosproject/screens/equations_mode_screen.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ModeSelectionScreen extends StatefulWidget {
  final AppUser profile;

  ModeSelectionScreen({required this.profile});

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller; // Initialise directement à la déclaration

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
  void initState() {
    super.initState();

    // Initialisation de l'AnimationController dans initState
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Durée de l'animation
      vsync: this, // Nécessaire pour l'AnimationController
    )..repeat(reverse: true); // Animation en boucle
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose pour éviter les fuites de mémoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E0854), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildLogo(),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(16),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildModeButton(
                      title: 'Progression',
                      color: Colors.red,
                      icon: 'assets/icons/progression_icon.png',
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressionModeScreen(profile: widget.profile))),
                    ),
                    _buildModeButton(
                      title: 'Astuces',
                      color: Colors.blue,
                      icon: 'assets/icons/tips_icon.png',
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RewardModeScreen(profile: widget.profile))),
                    ),
                    _buildModeButton(
                      title: 'Rapidité',
                      color: Colors.green,
                      icon: 'assets/chrono.png',
                      onPressed: () => _showStartConfirmation(context, 'Mode Rapidité', () => Navigator.push(context, MaterialPageRoute(builder: (context) => RapidityModeScreen(profile: widget.profile)))),
                    ),
                    _buildModeButton(
                      title: 'Précision',
                      color: Colors.orange,
                      icon: 'assets/icons/precision_icon.png',
                      onPressed: () => _showStartConfirmation(context, 'Mode Précision', () => Navigator.push(context, MaterialPageRoute(builder: (context) => PrecisionModeScreen(profile: widget.profile)))),
                    ),
                    _buildModeButton(
                      title: 'Équations',
                      color: Colors.purple,
                      icon: 'assets/icons/equations_icon.png',
                      onPressed: () => _showStartConfirmation(context, 'Mode Équations', () => Navigator.push(context, MaterialPageRoute(builder: (context) => EquationsModeScreen(profile: widget.profile)))),
                    ),
                    _buildModeButton(
                      title: 'Competition',
                      color: Colors.teal,
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

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Image.asset(
        'assets/logov3.png', // Remplace le texte par l'image
        width: 300,
        height: 150,
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required Color color,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + 0.05 * _controller.value,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(icon, width: 64, height: 64),
                  SizedBox(height: 8),
                  AutoSizeText(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      fontSize: 18,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    minFontSize: 10,
                    stepGranularity: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStartConfirmation(BuildContext context, String mode, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Commencer $mode?'),
        content: Text(modeDescriptions[mode] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text('Commencer'),
          ),
        ],
      ),
    );
  }

  void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pas de connexion'),
        content: Text('Vous devez être connecté à internet pour participer à la compétition.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/join_or_create_competition_screen.dart';
import 'package:mathosproject/screens/progression_mode_screen.dart';
import 'package:mathosproject/screens/reward_mode_screen.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';
import 'package:mathosproject/screens/problem_mode_screen.dart';
import 'package:mathosproject/screens/equations_mode_screen.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:mathosproject/widgets/pixel_circle.dart';
import 'package:mathosproject/widgets/pixel_transition.dart';

class ModeSelectionScreen extends StatefulWidget {
  final AppUser profile;

  ModeSelectionScreen({required this.profile});

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _hoveredIndex = -1;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<Map<String, dynamic>> modes = [
    {
      'name': 'PROGRESSION',
      'color': Color(0xFFFF0000),
      'icon': 'assets/progression.png',
      'description': 'Validez tous les opérateurs pour passer au niveau suivant. Chaque opérateur vous débloque une astuce.',
    },
    {
      'name': 'ASTUCES',
      'color': Color(0xFF0000FF),
      'icon': 'assets/astuce.png',
      'description': 'Découvrez ici les astuces débloquées dans le mode Progression.',
    },
    {
      'name': 'RAPIDITE',
      'color': Color(0xFF00FFFF),
      'icon': 'assets/speed.png',
      'description': 'Répondez le plus rapidement possible à un maximum de calculs. Vous avez 1 minute.',
    },
    {
      'name': 'PROBLEME',
      'color': Color(0xFF00FF00),
      'icon': 'assets/probleme.png',
      'description': 'Résolvez le plus rapidement possible les problèmes. Vous avez 2 minutes.',
    },
    {
      'name': 'EQUATION',
      'color': Color(0xFFEC003E),
      'icon': 'assets/equation.png',
      'description': 'Résolvez le plus rapidement possible les équations. Vous avez 1 minute.',
    },
    {
      'name': 'COMPETITION',
      'color': Color(0xFF02A6CC),
      'icon': 'assets/competition.png',
      'description': 'Créez ou rejoignez une compétition pour défier vos amis.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      modes.length,
          (index) => AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) =>
        Tween<double>(begin: 1.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        )
    ).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onHover(int index, bool isHovered) {
    setState(() {
      _hoveredIndex = isHovered ? index : -1;
    });
    if (isHovered) {
      _controllers[index].forward();
    } else {
      _controllers[index].reverse();
    }
  }

  void _selectMode(int index) {
    _showStartConfirmation(context, modes[index]['name'], () {
      _showButtonAnimation(index);
      Future.delayed(Duration(milliseconds: 500), () {
        switch (index) {
          case 0:
          case 0:
            print("Avant la navigation vers ProgressionModeScreen");
            Navigator.push(context, PixelTransition(page: ProgressionModeScreen(profile: widget.profile)));
            print("Après la navigation vers ProgressionModeScreen");
            break;
          case 1:
            Navigator.push(context, PixelTransition(page :RewardModeScreen(profile: widget.profile)));
            break;
          case 2:
            Navigator.push(context,PixelTransition(page :RapidityModeScreen(profile: widget.profile)));
            break;
          case 3:
            Navigator.push(context, PixelTransition(page :ProblemModeScreen(profile: widget.profile)));
            break;
          case 4:
            Navigator.push(context, PixelTransition(page :EquationsModeScreen(profile: widget.profile)));
            break;
          case 5:
            _checkConnectionAndNavigate();
            break;
        }
      });
    });
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _showStartConfirmation(BuildContext context, String mode, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF564560),
        title: Text('$mode',
            style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 18)),
        content: Text(modes.firstWhere((m) => m['name'] == mode)['description'],
            style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text('Commencer', style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
          ),TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
          ),

        ],
      ),
    );
  }

  void _showButtonAnimation(int index) {
    _controllers[index].forward().then((_) => _controllers[index].reverse());
  }

  void _checkConnectionAndNavigate() async {
    bool isConnected = await ConnectivityManager().isConnected();
    if (isConnected) {
      Navigator.push(context, _createRoute(JoinOrCreateCompetitionScreen(profile: widget.profile)));
    } else {
      _showNoConnectionDialog();
    }
  }

  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2E0854),
        title: Text('NO CONNECTION', style: TextStyle(color: Color(0xFFFF0000), fontFamily: 'PixelFont')),
        content: Text('Internet connection required for competition mode.', style: TextStyle(color: Color(0xFFF0F0F0), fontFamily: 'PixelFont')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF00A0FF), fontFamily: 'PixelFont')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF564560),
      body: SafeArea(
        child: Column(
          children: [
            _buildLogo(),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: modes.length,
                itemBuilder: (context, index) => _buildModeButton(index),
              ),
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

  Widget _buildLogo() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Image.asset('assets/logov3.png', width: 300, height: 100),
    );
  }

  Widget _buildModeButton(int index) {
    return MouseRegion(
      onEnter: (_) => _onHover(index, true),
      onExit: (_) => _onHover(index, false),
      child: GestureDetector(
        onTap: () => _selectMode(index),
        child: PixelCircle(
          color: modes[index]['color'] as Color,
          size: MediaQuery.of(context).size.width / 2.5,
          onPressed: () => _selectMode(index),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      modes[index]['icon'] as String,
                      width: 60,
                      height: 60,
                    ),
                    SizedBox(height: 8),
                    Text(
                      modes[index]['name'] as String,
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 11,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
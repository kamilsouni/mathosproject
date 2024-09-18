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

class ModeSelectionScreen extends StatefulWidget {
  final AppUser profile;

  ModeSelectionScreen({required this.profile});

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _hoveredIndex = -1;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> modes = [
    {
      'name': 'PROGRESSION',
      'color': Color(0xFFFF0000),
      'icon':  'assets/progression.png', // Chemin vers votre icône
      'description': 'Validez les opérations pour passer au niveau suivant.',
    },
    {
      'name': 'ASTUCES',
      'color': Color(0xFF0000FF),
      'icon': 'assets/astuce.png',
      'description': 'Débloquez des astuces pour chaque niveau réussi.',
    },
    {
      'name': 'RAPIDITE',
      'color': Color(0xFF00FFFF),
      'icon': 'assets/speed.png',
      'description': 'Répondez rapidement en 1 minute.',
    },
    {
      'name': 'PRECISION',
      'color': Color(0xFF00FF00),
      'icon': 'assets/target.png',
      'description': 'Soyez précis dans vos calculs.',
    },
    {
      'name': 'EQUATIONS',
      'color': Color(0xFFEC003E),
      'icon': 'assets/progression.png',
      'description': 'Résolvez des équations à trou.',
    },
    {
      'name': 'COMPETITION',
      'color': Color(0xFF02A6CC),
      'icon': 'assets/competition.png',
      'description': 'Défiez d\'autres joueurs en ligne.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                physics: NeverScrollableScrollPhysics(),
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
    return GestureDetector(
      onTapDown: (_) => _onTapDown(index),
      onTapUp: (_) => _onTapUp(index),
      onTapCancel: () => _onTapCancel(),
      onTap: () => _selectMode(index),
      onLongPress: () => _showDescription(index),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoveredIndex == index ? _animation.value : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: modes[index]['color'],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: modes[index]['color'].withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.white,  // Appliquer le filtre blanc à toutes les icônes
                        BlendMode.srcATop,
                      ),
                      child: Image.asset(
                        modes[index]['icon'],  // Utiliser une image d'asset pour l'icône
                        width: 40,
                        height: 40,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      modes[index]['name'],
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 14,
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
            ),
          );
        },
      ),
    );
  }


  void _onTapDown(int index) {
    setState(() {
      _hoveredIndex = index;
    });
    _controller.forward();
  }

  void _onTapUp(int index) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _showDescription(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2E0854),
          title: Text(modes[index]['name'],
              style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
          content: Text(modes[index]['description'],
              style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _selectMode(int index) {
    _showStartConfirmation(context, modes[index]['name'], () {
      _showButtonAnimation(index);
      Future.delayed(Duration(milliseconds: 500), () {
        switch (index) {
          case 0:
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressionModeScreen(profile: widget.profile)));
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (context) => RewardModeScreen(profile: widget.profile)));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (context) => RapidityModeScreen(profile: widget.profile)));
            break;
          case 3:
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProblemModeScreen(profile: widget.profile)));
            break;
          case 4:
            Navigator.push(context, MaterialPageRoute(builder: (context) => EquationsModeScreen(profile: widget.profile)));
            break;
          case 5:
            _checkConnectionAndNavigate();
            break;
        }
      });
    });
  }

  void _showStartConfirmation(BuildContext context, String mode, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2E0854),
        title: Text('Commencer $mode?',
            style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
        content: Text(modes.firstWhere((m) => m['name'] == mode)['description'],
            style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text('Commencer', style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
          ),
        ],
      ),
    );
  }

  void _showButtonAnimation(int index) {
    setState(() {
      _hoveredIndex = index;
    });
    _controller.forward().then((_) => _controller.reverse());
  }

  void _checkConnectionAndNavigate() async {
    bool isConnected = await ConnectivityManager().isConnected();
    if (isConnected) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => JoinOrCreateCompetitionScreen(profile: widget.profile)));
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
}
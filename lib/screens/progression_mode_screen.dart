import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mathosproject/dialog_manager.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/progression_screen.dart';
import 'package:mathosproject/screens/reward_mode_screen.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.yellow,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> startTest(String operation, int level) async {
    final result = await Navigator.push<Map<String, dynamic>>(
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
    );

    if (result != null && mounted) {
      // Valider l'opérateur
      bool isLevelComplete = widget.profile.validateOperator(level, operation);
      await UserPreferences.updateProfileInFirestore(widget.profile);

      if (!mounted) return;

      if (isLevelComplete) {
        // Attendre un court instant pour s'assurer que le précédent écran est bien démonté
        await Future.delayed(Duration(milliseconds: 100));

        if (!mounted) return;

        // Utiliser DialogManager pour garder l'apparence cohérente
        await DialogManager.showCustomDialog(
          context: context,
          title: 'Niveau débloqué !',
          content: 'Vous avez débloqué le niveau ${level + 1}.',
          confirmText: 'OK',
          onConfirm: () {
            setState(() {
              widget.profile.updateAccessibility();
            });
          },
          buttonColor: Colors.green,
        );
      } else {
        // Dialogue pour l'opérateur validé
        await DialogManager.showCustomDialog(
          context: context,
          title: 'Félicitations!',
          content: 'Vous avez validé les ${operation.toLowerCase()}s du niveau $level.',
          confirmText: 'OK',
          onConfirm: () {
            setState(() {
              widget.profile.updateAccessibility();
            });
          },
          buttonColor: Colors.green,
        );
      }
    }
  }

  void _handleBackPress() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF564560),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ModeSelectionScreen(profile: widget.profile),
      ),
    );
  }






  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        _handleBackPress();
        return false;
      },
      child: Scaffold(
        appBar: TopAppBar(
          title: 'Mode Progression',
          showBackButton: true,
          onBackPressed: _handleBackPress,
        ),
        body: Container(
          color: Color(0xFF564560),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
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
                                    fontFamily: 'PixelFont',
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildOperationButton(
                                      'Addition',
                                      level,
                                      screenWidth,
                                      screenHeight,
                                    ),
                                    _buildOperationButton(
                                      'Soustraction',
                                      level,
                                      screenWidth,
                                      screenHeight,
                                    ),
                                    _buildOperationButton(
                                      'Multiplication',
                                      level,
                                      screenWidth,
                                      screenHeight,
                                    ),
                                    _buildOperationButton(
                                      'Division',
                                      level,
                                      screenWidth,
                                      screenHeight,
                                    ),
                                    _buildOperationButton(
                                      'Mixte',
                                      level,
                                      screenWidth,
                                      screenHeight,
                                      isMixte: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
      ),
    );
  }

  Widget _buildOperationButton(
      String operation,
      int level,
      double screenWidth,
      double screenHeight, {
        bool isMixte = false,
      }) {
    bool isAccessible =
        widget.profile.progression[level]?[operation]?['accessibility'] == 1;
    bool isValidated =
        widget.profile.progression[level]?[operation]?['validation'] == 1;

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
          onPressed: isAccessible
              ? () async {
            await SoundManager.playButtonClickSound();
            startTest(operation, level);
          }
              : null,
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
}
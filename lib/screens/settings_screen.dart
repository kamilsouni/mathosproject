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
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final AppUser profile;

  SettingsScreen({required this.profile});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEffectsEnabled = SoundManager.isSoundEnabled();
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = SoundManager.isVibrationEnabled();

  // Constantes pour les tailles de police
  late final double _titleFontSize;
  late final double _contentFontSize;
  late final double _sectionTitleFontSize;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.yellow,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Size screenSize = MediaQuery.of(context).size;
    _titleFontSize = screenSize.height * 0.022;
    _contentFontSize = screenSize.height * 0.018;
    _sectionTitleFontSize = screenSize.height * 0.02;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
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
    height: screenSize.height,
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
    'Vibrations',
    _vibrationEnabled,
    (value) {
    setState(() {
    _vibrationEnabled = value;
    SoundManager.setVibrationEnabled(value);
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
    ], screenSize),_buildSection('Confidentialité', [
        _buildSubsection('Politique', () {
          _showDialog('Politique de Confidentialité',
              '• Vos données sont stockées de manière sécurisée sur Firebase et Hive\n\n'
                  '• Nous utilisons vos données uniquement pour améliorer votre expérience de jeu\n\n'
                  '• Aucune donnée n\'est partagée avec des tiers (même s\'ils demandent gentiment)\n\n'
                  '• Vos scores sont sauvegardés localement quand vous êtes hors ligne\n\n'
                  '• La synchronisation se fait automatiquement quand vous retrouvez une connexion',
              screenSize);
        }, screenSize),
        _buildSubsection('Conditions', () {
          _showDialog('Conditions d\'Utilisation',
              '• En utilisant cette application, vous acceptez de devenir un champion des mathématiques\n\n'
                  '• Pas de calculatrice autorisée ! Vos neurones sont vos seuls alliés\n\n'
                  '• Les scores sont vérifiés par nos robots mathématiciens. Ils ne se trompent jamais, ou presque!\n\n'
                  '• En cas de dispute avec l\'application, c\'est toujours l\'application qui a raison (désolé!)\n\n'
                  ,
              screenSize);
        }, screenSize),
      ], screenSize),
      _buildSection('À propos', [
        _buildSubsection('Développeurs', () {
          _showDialog('À Propos des Développeurs',
              'Bienvenue dans une application qui vous rend vraiment plus intelligent!\n\n'
                  '• Créée avec l\'aide d\'IA pour rendre les maths amusantes\n\n'
                  '• Pendant que les autres apps vous font perdre des neurones, celle-ci en crée!\n\n'
                  '• Si vous trouvez un bug, c\'est probablement une fonctionnalité secrète pour tester votre patience\n\n'
,
              screenSize);
        }, screenSize),
        _buildSubsection('Version', () {
          _showDialog('Version de l\'Application', 'Version 1.0\n\nCodée avec ❤️ et 🤖', screenSize);
        }, screenSize),
      ], screenSize),
      _buildSection('Mode hors-ligne', [
        _buildSubsection('Fonctionnement', () {
          _showDialog('Mode Hors-Ligne',
              '• Tous les modes de jeu sont disponibles hors-ligne, sauf le mode compétition\n\n'
                  '• Vos scores sont sauvegardés localement\n\n'
                  '• La synchronisation se fait automatiquement au retour de la connexion\n\n'
                  '• Même hors-ligne, les maths restent les maths !',
              screenSize);
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
            fontSize: _sectionTitleFontSize,
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
          borderRadius: BorderRadius.zero,
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
                  fontSize: _contentFontSize,
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
        borderRadius: BorderRadius.zero,
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
                fontSize: _contentFontSize,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.yellow, width: 2),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.yellow,
              fontFamily: 'PixelFont',
              fontSize: _titleFontSize,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PixelFont',
                fontSize: _contentFontSize,
              ),
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
                  fontSize: _contentFontSize,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.yellow, width: 2),
          ),
          title: Text(
            "Modes de jeu",
            style: TextStyle(
              color: Colors.yellow,
              fontFamily: 'PixelFont',
              fontSize: _titleFontSize,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoringSystemText('Mode Rapidité', [
                  '• Course contre la montre de 60 secondes pour exploser ton score',
                  '• Trois bonnes réponses = montée de niveau',
                  '• Question passée = descente de niveau',
                  '• Plus tu réponds vite, plus tu gagnes de points bonus',
                  '• Chaque niveau augmente la difficulté et les récompenses',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Problème', [
                  '• 2 minutes pour résoudre un maximum de problèmes',
                  '• Trois succès consécutifs = nouveau niveau',
                  '• Difficulté progressive avec les niveaux',
                  '• Mode parfait pour entraîner ton raisonnement',
                  '• Bonus de points pour les réponses rapides',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Équations', [
                  '• Trouve le nombre ou l\'opérateur manquant',
                  '• 60 secondes pour marquer un maximum de points',
                  '• Trois bonnes réponses = niveau supérieur',
                  '• Question passée = retour au niveau précédent',
                  '• Bonus de vitesse pour les réponses éclair',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Progression', [
                  '• Maîtrise chaque opération une par une',
                  '• Débloque des astuces en validant les niveaux',
                  '• Progression personnalisée et adaptative',
                  '• Mode mixte disponible après validation',
                  '• Idéal pour progresser méthodiquement',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Compétition', [
                  '• Défie tes amis en temps réel',
                  '• Choisis le nombre de tests par type',
                  '• Classement en direct des participants',
                  '• Points bonus pour les performances exceptionnelles',
                  '• Deviens le champion des mathématiques !',
                ]),
              ],
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
                  fontSize: _contentFontSize,
                ),
              ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.yellow, width: 2),
          ),
          title: Text(
            "Système de points",
            style: TextStyle(
                color: Colors.yellow,
                fontFamily: 'PixelFont',
                fontSize: _titleFontSize
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoringSystemText('Mode Rapidité', [
                  '• 10 points × niveau par bonne réponse',
                  '• Bonus de rapidité : +50 points',
                  '• Question passée : -100 points et niveau -1',
                  '• Bonus de série : +50 points tous les 3 succès',
                  '• Multiplicateur de niveau pour tous les points',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Problème', [
                  '• 50 points × niveau par bonne réponse',
                  '• Bonus de série : +50 points pour 3 succès',
                  '• Question passée : -100 points et niveau -1',
                  '• Bonus de temps restant en fin de partie',
                  '• Points doublés au-delà du niveau 5',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Équations', [
                  '• 10 points × niveau par bonne réponse',
                  '• Bonus de niveau : +100 points par niveau',
                  '• Mauvaise réponse : -5 points et niveau -1',
                  '• Bonus de série : +25 points tous les 5 succès',
                  '• Points triplés pour les équations complexes',
                ]),
                SizedBox(height: 10),
                _buildScoringSystemText('Mode Progression', [
                  '• 10 points × niveau par bonne réponse',
                  '• Bonus de validation : +100 points par niveau',
                  '• Question passée : -100 points',
                  '• Super bonus de maîtrise : +500 points',
                  '• Points spéciaux pour mode mixte validé',
                ]),
              ],
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
                  fontSize: _contentFontSize,
                ),
              ),
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
          style: TextStyle(
            color: Colors.yellow,
            fontFamily: 'PixelFont',
            fontSize: _contentFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pointsInfo.map((info) {
            return Padding(
              padding: EdgeInsets.only(left: 8.0, top: 4.0),
              child: Text(
                info,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PixelFont',
                  fontSize: _contentFontSize * 0.9,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

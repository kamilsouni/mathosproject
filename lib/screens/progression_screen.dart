import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mathosproject/dialog_manager.dart';
import 'package:mathosproject/widgets/RetroCalculator.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
import 'package:mathosproject/math_test_utils.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/progression_mode_screen.dart';
import 'package:mathosproject/widgets/game_app_bar.dart';
import 'package:mathosproject/widgets/retro_progress_bar.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';

class ProgressionScreen extends StatefulWidget {
  final String mode;
  final AppUser profile;
  final bool isInitialTest;
  final bool isCompetition;
  final int duration;
  final int level;

  ProgressionScreen({
    required this.mode,
    required this.profile,
    required this.isInitialTest,
    required this.isCompetition,
    required this.duration,
    required this.level,
  });

  @override
  _ProgressionScreenState createState() => _ProgressionScreenState();
}

class _ProgressionScreenState extends State<ProgressionScreen> {
  late int _difficultyLevel;
  late int _currentAnswer;
  late String _currentQuestion;
  late TextEditingController _answerController;
  late FocusNode _focusNode;
  late int _correctAnswers;
  late int _skippedQuestions;
  late Stopwatch _stopwatch;
  late List<int> _responseTimes;
  late int _points;
  late int _pointsChange;
  late List<bool> _answerHistory;
  late Map<String, List<bool>> _operationResults;
  late List<Map<String, dynamic>> _errorDetails;
  late String _currentOperation;
  bool _isAnswerCorrect = false;
  bool _isSkipped = false;

  // Variables pour la validation rapide
  int _consecutiveQuickAnswers = 0; // Nombre de réponses consécutives rapides
  double _totalQuickTime = 0; // Temps total pour les réponses rapides
  final int _quickThreshold = 10; // Nombre de réponses rapides nécessaires

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.yellow,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _difficultyLevel = widget.isCompetition || widget.isInitialTest ? 1 : widget.level;
    _currentAnswer = 0;
    _currentQuestion = "";
    _answerController = TextEditingController();
    _focusNode = FocusNode();
    _correctAnswers = 0;
    _skippedQuestions = 0;
    _stopwatch = Stopwatch();
    _responseTimes = [];
    _points = 0;
    _pointsChange = 0;
    _answerHistory = [];
    _isSkipped = false;
    _operationResults = {
      'Addition': [],
      'Soustraction': [],
      'Multiplication': [],
      'Division': [],
      'Mixte': []
    };
    _errorDetails = [];
    _currentOperation = 'Addition';
    generateQuestion();
    _answerController.addListener(_checkAnswer);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _answerController.removeListener(_checkAnswer);
    _answerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_answerController.text.isNotEmpty) {
      int? userAnswer = int.tryParse(_answerController.text);
      if (userAnswer != null && userAnswer == _currentAnswer) {
        _stopwatch.stop(); // Arrête le chronomètre pour la question
        int responseTime = _stopwatch.elapsedMilliseconds; // Temps en millisecondes
        double responseTimeInSeconds = responseTime / 1000; // Convertir en secondes

        // Vérification de la rapidité
        if (responseTimeInSeconds < 2) { // Si la réponse est rapide (< 2 secondes)
          _consecutiveQuickAnswers++;
          _totalQuickTime += responseTimeInSeconds;
        } else {
          _consecutiveQuickAnswers = 0; // Réinitialiser si la réponse est lente
          _totalQuickTime = 0;
        }

        // Validation automatique si la condition est remplie
        if (_consecutiveQuickAnswers >= _quickThreshold) {
          _validateQuickly();
          return; // Arrêter ici, le niveau est validé
        }

        submitAnswer(); // Continuer le traitement normal
      }
    }
    setState(() {}); // Pour forcer la mise à jour de l'affichage
  }

  void generateQuestion() {
    final result = MathTestUtils.generateQuestion(widget.level, widget.mode);
    setState(() {
      _currentQuestion = result['question'];
      _currentAnswer = result['answer'];
      _isAnswerCorrect = false;
      _isSkipped = false;
      _answerController.clear();
    });
  }

  void submitAnswer() {
    setState(() {
      _correctAnswers++;
      _points += 10 * widget.level;
    });

    // Redémarrer le chronomètre pour la prochaine question
    _stopwatch.reset();
    _stopwatch.start();

    // Générer la prochaine question
    if (_correctAnswers < 30) {
      generateQuestion();
    } else {
      _showValidationMessage(); // Validation classique si toutes les questions sont complétées
    }
  }

  void skipQuestion() {
    setState(() {
      _isSkipped = true;
      _isAnswerCorrect = false;
      _skippedQuestions++;
      _pointsChange = -100;
      _points -= 100;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isSkipped = false;
        _answerController.clear();
      });
      generateQuestion();
    });
  }

  void _validateQuickly() {
    setState(() {
      _correctAnswers = 30; // Considérer que toutes les réponses requises sont validées
      _stopwatch.stop(); // Arrêter toute mesure de temps
    });

    // Ajouter les points au profil
    widget.profile.points += _points;
    updateProfile(widget.profile);

    // Afficher un message pour informer l'utilisateur
    DialogManager.showCustomDialog(
      context: context,
      title: 'Niveau validé !',
      content: 'Vous avez validé ce niveau grâce à votre rapidité exceptionnelle.',
      confirmText: 'OK',
      onConfirm: () {
        Navigator.of(context).pop();
        _validateLevel(); // Passer au niveau suivant
      },
      buttonColor: Colors.green,
    );
  }

  void _endTest() {
    if (_correctAnswers < 30) {
      _showEncouragementMessage();
    } else {
      widget.profile.points += _points; // Ajouter les points au profil de l'utilisateur
      updateProfile(widget.profile).then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProgressionModeScreen(profile: widget.profile),
          ),
        );
      });
    }
  }

  void _showEncouragementMessage() {
    DialogManager.showCustomDialog(
      context: context,
      title: 'Essayez encore !',
      content: 'Vous n\'avez pas encore validé les ${widget.mode.toLowerCase()}s du niveau ${widget.level}. Essayez encore !',
      confirmText: 'OK',
      onConfirm: () {
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProgressionModeScreen(profile: widget.profile),
          ),
        );
      },
      buttonColor: Color(0xFF564560),
    );
  }

  Future<void> updateProfile(AppUser profile) async {
    if (await ConnectivityManager().isConnected()) {
      await UserPreferences.updateProfileInFirestore(profile);
    } else {
      await UserPreferences.saveProfileLocally(profile);
    }
  }

  void _validateLevel() {
    widget.profile.validateOperator(widget.level, widget.mode);
    updateProfile(widget.profile);

    if (widget.profile.progression[widget.level]!.values
        .every((element) => element['validation'] == 1)) {
      _showLevelUnlockedMessage();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProgressionModeScreen(profile: widget.profile),
        ),
      );
    }
  }

  void _showValidationMessage() {
    widget.profile.points += _points; // Ajouter les points au profil de l'utilisateur
    updateProfile(widget.profile); // Mettre à jour le profil de l'utilisateur

    DialogManager.showCustomDialog(
      context: context,
      title: 'Félicitations!',
      content: 'Vous avez validé les ${widget.mode.toLowerCase()}s du niveau ${widget.level}.',
      confirmText: 'OK',
      onConfirm: () {
        Navigator.of(context).pop();
        _validateLevel();
      },
      buttonColor: Colors.green,
    );
  }

  void _showLevelUnlockedMessage() {
    DialogManager.showCustomDialog(
      context: context,
      title: 'Niveau débloqué!',
      content: 'Vous avez débloqué le niveau ${widget.level + 1}.',
      confirmText: 'OK',
      onConfirm: () {
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProgressionModeScreen(profile: widget.profile),
          ),
        );
      },
      buttonColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(points: _points, lastChange: _pointsChange),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xFF564560), // Fond violet
            ),
          ),
          Column(
            children: [
              SizedBox(height: 20),
              RetroProgressBar(
                currentValue: _correctAnswers,
                maxValue: 30,
                height: 20,
                fillColor: Colors.green,
                backgroundColor: Colors.black,
              ),
              SizedBox(height: 20),
              CountdownTimer(
                duration: 61,
                onCountdownComplete: _endTest,
                progressColor: Colors.green,
                height: 20,
              ),
              SizedBox(height: 40),
              Expanded(
                child: RetroCalculator(
                  question: _currentQuestion,
                  answer: _answerController.text,
                  controller: _answerController,
                  onSubmit: skipQuestion,
                  onDelete: () {
                    if (_answerController.text.isNotEmpty) {
                      setState(() {
                        _answerController.text =
                            _answerController.text.substring(0, _answerController.text.length - 1);
                      });
                    }
                  },
                  isCorrectAnswer: _isAnswerCorrect,
                  isSkipped: _isSkipped,
                  isProgressMode: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

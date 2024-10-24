import 'package:flutter/material.dart';
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


  @override
  void initState() {
    super.initState();
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
        submitAnswer();
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
    MathTestUtils.submitAnswer(
      userAnswer: _answerController.text,
      correctAnswer: _currentAnswer,
      responseTimes: _responseTimes,
      stopwatch: _stopwatch,
      answerHistory: _answerHistory,
      operationResults: _operationResults,
      operation: _currentOperation,
      points: _points,
      onCorrect: () {
        setState(() {
          _correctAnswers++;
          _pointsChange = 10 * widget.level;
          _points += _pointsChange;
          _isAnswerCorrect = true;
          _isSkipped = false;
          if (_correctAnswers >= 30) {
            _showValidationMessage();
          }
        });
      },
      onIncorrect: () {
        setState(() {
          _skippedQuestions++;
          _pointsChange = -10;
          _points -= 10;
          _correctAnswers = _correctAnswers >= 2 ? _correctAnswers - 2 : 0;
          _isAnswerCorrect = false;
          _isSkipped = false;
        });
      },
    );

    // Réinitialiser l'état après un court délai
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isAnswerCorrect = false;
        _isSkipped = false;
        _answerController.clear();
      });
      if (_correctAnswers < 30) {
        generateQuestion();
      }
    });
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

    // Utilisation du DialogManager pour afficher le message de validation
    DialogManager.showCustomDialog(
      context: context,
      title: 'Félicitations!',  // Titre du dialogue
      content: 'Vous avez validé les ${widget.mode.toLowerCase()}s du niveau ${widget.level}.',  // Contenu dynamique
      confirmText: 'OK',  // Texte du bouton de confirmation
      cancelText: '',  // Pas de bouton "Annuler"
      onConfirm: () {
        Navigator.of(context).pop();  // Fermer le dialogue
        _validateLevel();  // Valider le niveau après avoir fermé le message de félicitations
      },
    );
  }

  void _showLevelUnlockedMessage() {
    // Utilisation du DialogManager pour afficher le message de niveau débloqué
    DialogManager.showCustomDialog(
      context: context,
      title: 'Niveau débloqué!',  // Titre du dialogue
      content: 'Vous avez débloqué le niveau ${widget.level + 1}.',  // Contenu dynamique
      confirmText: 'OK',  // Texte du bouton de confirmation
      cancelText: '',  // Pas de bouton "Annuler"
      onConfirm: () {
        Navigator.of(context).pop();  // Fermer le dialogue
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProgressionModeScreen(profile: widget.profile),  // Naviguer vers l'écran de progression
          ),
        );
      },
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
    // Utilisation du DialogManager pour afficher le message d'encouragement
    DialogManager.showCustomDialog(
      context: context,
      title: 'Essayez encore!',  // Titre du dialogue
      content: 'Vous n\'avez pas encore validé les ${widget.mode.toLowerCase()}s du niveau ${widget.level}. Essayez encore!',  // Contenu dynamique
      confirmText: 'OK',  // Texte du bouton de confirmation
      cancelText: '',  // Pas de bouton "Annuler"
      onConfirm: () {
        Navigator.of(context).pop();  // Fermer le dialogue
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProgressionModeScreen(profile: widget.profile),  // Naviguer vers l'écran de progression
          ),
        );
      },
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
                  onSubmit: skipQuestion,  // Changez ceci de submitAnswer à skipQuestion
                  onDelete: () {
                    if (_answerController.text.isNotEmpty) {
                      setState(() {
                        _answerController.text = _answerController.text.substring(0, _answerController.text.length - 1);
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mathosproject/screens/end_game_analysis_screen.dart';
import 'package:mathosproject/widgets/RetroCalculator.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
import 'package:mathosproject/math_test_utils.dart';
import 'package:mathosproject/models/app_user.dart';
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
    required this.duration,
    required this.level,
    this.isCompetition = false,

  });

  @override
  _ProgressionScreenState createState() => _ProgressionScreenState();
}

class _ProgressionScreenState extends State<ProgressionScreen> {
  bool _isGameOver = false;  // Ajoutez ici
  late String _currentQuestion;
  late int _currentAnswer;
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
  int _consecutiveQuickAnswers = 0;
  double _totalQuickTime = 0;
  final int _quickThreshold = 10;
  List<Map<String, dynamic>> _operationsHistory = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.yellow,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
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
    _operationsHistory = [];
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
        _stopwatch.stop();
        int responseTime = _stopwatch.elapsedMilliseconds;
        double responseTimeInSeconds = responseTime / 1000;

        if (responseTimeInSeconds < 2) {
          _consecutiveQuickAnswers++;
          _totalQuickTime += responseTimeInSeconds;
        } else {
          _consecutiveQuickAnswers = 0;
          _totalQuickTime = 0;
        }

        if (_consecutiveQuickAnswers >= _quickThreshold) {
          _validateQuickly();
          return;
        }
        submitAnswer();
      }
    }
    setState(() {});
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

      // Ajout de l'opération à l'historique
      _operationsHistory.add({
        'question': _currentQuestion,
        'answer': _answerController.text,
        'isCorrect': true,
      });
    });

    _stopwatch.reset();
    _stopwatch.start();

    if (_correctAnswers < 30) {
      generateQuestion();
    } else {
      _onCountdownComplete();
    }
  }

  void skipQuestion() {
    setState(() {
      _isSkipped = true;
      _isAnswerCorrect = false;
      _skippedQuestions++;
      _pointsChange = -100;
      _points -= 100;

      // Ajout de l'opération sautée à l'historique
      _operationsHistory.add({
        'question': _currentQuestion,
        'answer': 'Passé',
        'isCorrect': false,
      });
    });

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isSkipped = false;
        _answerController.clear();
      });
      generateQuestion();
    });
  }



  Future<void> _validateQuickly() async {  // Ajout du async
    if (_isGameOver) return;

    setState(() => _isGameOver = true);

    // Valider l'opérateur
    widget.profile.validateOperator(widget.level, widget.mode);
    widget.profile.points += _points;

    // Sauvegarder les données du profil
    if (await ConnectivityManager().isConnected()) {
      await UserPreferences.updateProfileInFirestore(widget.profile);
    } else {
      await UserPreferences.saveProfileLocally(widget.profile);
    }

    // Naviguer vers l'écran de fin
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EndGameAnalysisScreen(
          score: 10, // Score fixe car c'est une validation rapide
          totalQuestionsNeeded: 10, // Objectif pour validation rapide
          operationsHistory: _operationsHistory,
          initialRecord: 0,
          gameMode: 'progression',
          isCompetition: false,
          profile: widget.profile,
          level: widget.level,
          isProgressionMode: true,
          operationType: widget.mode,
          isQuickValidation: true,
          hasValidatedOperator: true, // Indique que l'opérateur est validé
        ),
      ),
    );
  }



  Future<void> updateProfile(AppUser profile) async {
    if (await ConnectivityManager().isConnected()) {
      await UserPreferences.updateProfileInFirestore(profile);
    } else {
      await UserPreferences.saveProfileLocally(profile);
    }
  }



  Future<void> _onCountdownComplete() async {
    if (_isGameOver) return;

    setState(() => _isGameOver = true);

    // Valider l'opérateur si 30 bonnes réponses
    bool hasValidatedOperator = false;
    if (_correctAnswers >= 30) {
      widget.profile.validateOperator(widget.level, widget.mode);
      hasValidatedOperator = true;
    }

    widget.profile.points += _points;

    // Sauvegarder les données du profil
    if (await ConnectivityManager().isConnected()) {
      await UserPreferences.updateProfileInFirestore(widget.profile);
    } else {
      await UserPreferences.saveProfileLocally(widget.profile);
    }

    // Naviguer vers l'écran de fin
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EndGameAnalysisScreen(
          score: _correctAnswers,
          totalQuestionsNeeded: 30, // Objectif pour validation normale
          operationsHistory: _operationsHistory,
          initialRecord: 0,
          gameMode: 'progression',
          isCompetition: false,
          profile: widget.profile,
          level: widget.level,
          isProgressionMode: true,
          operationType: widget.mode,
          isQuickValidation: false,
          hasValidatedOperator: hasValidatedOperator,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
    onWillPop: () async {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.yellow,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
      Navigator.pop(context);
      return false;
    },
    child: Scaffold(
      appBar: GameAppBar(
        points: _points,
        lastChange: _pointsChange,
        isInGame: true,
        onBackPressed: () {
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Colors.yellow,
              statusBarIconBrightness: Brightness.dark,
            ),
          );
          Navigator.pop(context);
        },
      ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Color(0xFF564560)),
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
                  duration: widget.duration,
                  onCountdownComplete: _onCountdownComplete,
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
                          _answerController.text = _answerController.text.substring(
                              0, _answerController.text.length - 1);
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
      ),
    );
  }
}
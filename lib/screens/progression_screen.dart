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
    });

    _stopwatch.reset();
    _stopwatch.start();

    if (_correctAnswers < 30) {
      generateQuestion();
    } else {
      _showValidationMessage();
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
    Navigator.of(context).pop({
      'success': true,
      'mode': widget.mode,
      'level': widget.level,
      'points': _points,
      'isQuickValidation': true,
    });
  }

  Future<void> updateProfile(AppUser profile) async {
    if (await ConnectivityManager().isConnected()) {
      await UserPreferences.updateProfileInFirestore(profile);
    } else {
      await UserPreferences.saveProfileLocally(profile);
    }
  }

  void _showValidationMessage() {
    widget.profile.points += _points;
    updateProfile(widget.profile);

    // Retourner le résultat au parent
    Navigator.of(context).pop({
      'success': true,
      'mode': widget.mode,
      'level': widget.level,
      'points': _points,
      'isQuickValidation': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: GameAppBar(
          points: _points,
          lastChange: _pointsChange,
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
                  onCountdownComplete: () {
                    Navigator.of(context).pop(null);
                  },
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
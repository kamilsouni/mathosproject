import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/widgets/custom_keyboard.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
import 'package:mathosproject/math_test_utils.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/progression_mode_screen.dart';
import 'package:mathosproject/widgets/game_app_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';

class MentalMathTestScreen extends StatefulWidget {
  final String mode;
  final AppUser profile;
  final bool isInitialTest;
  final bool isCompetition;
  final int duration;
  final int level;

  MentalMathTestScreen({
    required this.mode,
    required this.profile,
    required this.isInitialTest,
    required this.isCompetition,
    required this.duration,
    required this.level,
  });

  @override
  _MentalMathTestScreenState createState() => _MentalMathTestScreenState();
}

class _MentalMathTestScreenState extends State<MentalMathTestScreen> {
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
    if (_answerController.text.isNotEmpty &&
        int.tryParse(_answerController.text) == _currentAnswer) {
      submitAnswer();
    }
  }

  void generateQuestion() {
    final result = MathTestUtils.generateQuestion(_difficultyLevel, widget.mode);
    setState(() {
      _currentQuestion = result['question'];
      _currentAnswer = result['answer'];
      _answerController.text = "";
      _focusNode.requestFocus();
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
          _pointsChange = 10 * _difficultyLevel;
          _points += _pointsChange;
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
        });
      },
    );
    generateQuestion();
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Félicitations!'),
          content: Text(
              'Vous avez validé les ${widget.mode.toLowerCase()}s du niveau ${widget.level}.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _validateLevel(); // Valider le niveau après avoir fermé le message de félicitations
              },
            ),
          ],
        );
      },
    );
  }

  void _showLevelUnlockedMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Niveau débloqué!'),
          content: Text('Vous avez débloqué le niveau ${widget.level + 1}.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProgressionModeScreen(profile: widget.profile),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void endTest() {
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Essayez encore!'),
          content: Text(
              'Vous n\'avez pas encore validé les ${widget.mode.toLowerCase()}s du niveau ${widget.level}. Essayez encore!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProgressionModeScreen(profile: widget.profile),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GameAppBar(points: _points, lastChange: _pointsChange),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/fond_d_ecran.svg',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.15),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 16.0, right: 16.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.125),
                  Container(
                    width: screenWidth * 1,
                    height: screenHeight * 0.02,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: LinearPercentIndicator(
                      lineHeight: screenHeight * 0.02,
                      percent: _correctAnswers / 30.0,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.green,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  CountdownTimer(
                    duration: widget.duration,
                    onCountdownComplete: endTest,
                    textStyle: TextStyle(fontSize: screenHeight * 0.03),
                    progressColor: Colors.black.withOpacity(0.7),
                    height: screenHeight * 0.02,
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            top: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentQuestion,
                          style: TextStyle(
                              fontSize: screenHeight * 0.05,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Container(
                          width: screenWidth * 0.6,
                          child: TextField(
                            focusNode: _focusNode,
                            controller: _answerController,
                            keyboardType: TextInputType.none,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.05,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onSubmitted: (value) {
                              submitAnswer();
                              _focusNode.requestFocus();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomKeyboard(
                  controller: _answerController,
                  onSubmit: submitAnswer,
                  onDelete: () {
                    if (_answerController.text.isNotEmpty) {
                      setState(() {
                        _answerController.text = _answerController.text
                            .substring(0, _answerController.text.length - 1);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/widgets/RetroCalculator.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
import 'package:mathosproject/widgets/level_indicator.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/math_test_utils.dart';
import 'package:mathosproject/widgets/game_app_bar.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RapidityModeScreen extends StatefulWidget {
  final AppUser profile;
  final bool isCompetition;
  final String? competitionId;

  RapidityModeScreen({
    required this.profile,
    this.isCompetition = false,
    this.competitionId,
  });

  @override
  _RapidityModeScreenState createState() => _RapidityModeScreenState();
}

class _RapidityModeScreenState extends State<RapidityModeScreen> with WidgetsBindingObserver {
  late int _currentLevel;
  late int _correctAnswersInRow;
  late int _points;
  late int _pointsChange;
  late String _currentQuestion;
  late int _currentAnswer;
  late TextEditingController _answerController;
  bool _isAnswerCorrect = false;
  bool _isSkipped = false;

  @override
  void initState() {
    super.initState();
    _currentLevel = 1;
    _correctAnswersInRow = 0;
    _points = 0;
    _pointsChange = 0;
    _answerController = TextEditingController();
    _answerController.addListener(_checkAnswer);
    generateQuestion();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _answerController.removeListener(_checkAnswer);
    _answerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkAnswer() {
    if (_answerController.text.isNotEmpty) {
      int? userAnswer = int.tryParse(_answerController.text);
      if (userAnswer != null && userAnswer == _currentAnswer) {
        _validateCorrectAnswer();
      }
    }
    setState(() {}); // Pour forcer la mise à jour de l'affichage
  }

  void _validateCorrectAnswer() {
    setState(() {
      _isAnswerCorrect = true;
      _isSkipped = false;
      _correctAnswersInRow++;
      _pointsChange = 10 * _currentLevel;
      _points += _pointsChange;
      if (_correctAnswersInRow >= 3) {
        _currentLevel++;
        _correctAnswersInRow = 0;
        _pointsChange += 50;
        _points += 50;
      }
    });

    Future.delayed(Duration(milliseconds: 300), () {
      generateQuestion();
    });
  }

  void skipQuestion() {
    setState(() {
      _isSkipped = true;
      _isAnswerCorrect = false;
      _correctAnswersInRow = 0;
      _pointsChange = -5;
      _points += _pointsChange;
      if (_currentLevel > 1) {
        _currentLevel--;
      }
    });

    Future.delayed(Duration(milliseconds: 300), () {
      generateQuestion();
    });
  }

  void generateQuestion() {
    final result = MathTestUtils.generateQuestion(_currentLevel, 'Mixte');
    setState(() {
      _currentQuestion = result['question'];
      _currentAnswer = result['answer'];
      _isAnswerCorrect = false;
      _isSkipped = false;
      _answerController.text = "";
    });
  }

  Future<void> _endTest() async {
    if (widget.isCompetition && widget.competitionId != null) {
      await _updateCompetitionData();
    }

    widget.profile.updateRecords(
        newRapidPoints: _points,
        newPrecisionPoints: 0,
        newEquationPoints: 0
    );

    widget.profile.points += _points;

    _showEndGamePopup();

    Future.delayed(Duration.zero, () async {
      if (await widget.profile.isOnline()) {
        await UserPreferences.updateProfileInFirestore(widget.profile);
      } else {
        await widget.profile.saveToLocalStorage();
      }
    });
  }

  Future<void> _updateCompetitionData() async {
    var localData = await HiveDataManager.getData<Map<String, dynamic>>(
        'competitionParticipants_${widget.competitionId}', widget.profile.id) ?? {};

    localData['name'] = widget.profile.name;
    localData['rapidTests'] = (localData['rapidTests'] ?? 0) + 1;
    localData['totalPoints'] = (localData['totalPoints'] ?? 0) + _points;
    localData['flag'] = widget.profile.flag;

    await HiveDataManager.saveData(
        'competitionParticipants_${widget.competitionId}', widget.profile.id, localData);

    if (await ConnectivityManager().isConnected()) {
      await FirebaseFirestore.instance
          .collection('competitions')
          .doc(widget.competitionId)
          .collection('participants')
          .doc(widget.profile.id)
          .set(localData, SetOptions(merge: true));
    }
  }

  void _showEndGamePopup() {
    String message;
    String title;

    if (_points > 1500) {
      title = "Félicitations !";
      message = "Wow ! Vous avez obtenu $_points points 🎉. Vous êtes un vrai champion ! Continuez comme ça !";
    } else if (_points > 1000) {
      title = "Excellent travail !";
      message = "Bravo, vous avez obtenu $_points points 👍. Vous progressez très bien !";
    } else if (_points > 500) {
      title = "Bien joué !";
      message = "Bon travail ! Vous avez obtenu $_points points. Continuez à vous améliorer !";
    } else {
      title = "Continuez à essayer !";
      message = "Vous avez obtenu $_points points. Ne vous découragez pas, vous pouvez faire encore mieux 💪.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
            ),
          ],
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
              color: Color(0xFF564560),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 20),
              LevelIndicator(currentLevel: _currentLevel, maxLevel: 10),
              SizedBox(height: 20),
              CountdownTimer(
                duration: 60,
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
                        _answerController.text = _answerController.text.substring(0, _answerController.text.length - 1);
                      });
                    }
                  },
                  isCorrectAnswer: _isAnswerCorrect,
                  isSkipped: _isSkipped,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
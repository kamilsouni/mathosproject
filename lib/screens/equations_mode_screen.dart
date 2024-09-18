import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/widgets/arcade_console.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
import 'package:mathosproject/widgets/level_indicator.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/math_test_utils.dart';
import 'package:mathosproject/widgets/game_app_bar.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'dart:math';

class EquationsModeScreen extends StatefulWidget {
  final AppUser profile;
  final bool isCompetition;
  final String? competitionId;

  EquationsModeScreen({
    required this.profile,
    this.isCompetition = false,
    this.competitionId,
  });

  @override
  _EquationsModeScreenState createState() => _EquationsModeScreenState();
}

class _EquationsModeScreenState extends State<EquationsModeScreen>
    with TickerProviderStateMixin {
  late int _currentLevel;
  late int _correctAnswersInRow;
  late int _points;
  late int _pointsChange;
  late String _currentQuestion;
  late String _correctAnswer;
  late List<String> _answerChoices;
  late int _holePosition;
  bool hasTestStarted = false;
  bool? _isCorrect;

  late AnimationController _equationController;
  late Animation<double> _equationAnimation;

  List<AnimationController> _buttonControllers = [];
  List<Animation<double>> _buttonAnimations = [];

  @override
  void initState() {
    super.initState();
    _currentLevel = 1;
    _correctAnswersInRow = 0;
    _points = 0;
    _pointsChange = 0;
    _equationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _equationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _equationController, curve: Curves.easeInOut),
    );
    generateQuestion();
    _showStartDialog();
  }

  @override
  void dispose() {
    _equationController.dispose();
    for (var controller in _buttonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void generateQuestion() {
    final result = _generateEquationWithHole(_currentLevel);
    setState(() {
      _currentQuestion = result['question'];
      _correctAnswer = result['answer'];
      _answerChoices = result['choices'];
      _holePosition = result['holePosition'];
    });

    _equationController.reset();
    _equationController.forward();

    _buttonControllers.clear();
    _buttonAnimations.clear();
    for (int i = 0; i < _answerChoices.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 200 + (i * 100)),
        vsync: this,
      );
      _buttonControllers.add(controller);
      _buttonAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        ),
      );
      controller.forward();
    }
  }

  Map<String, dynamic> _generateEquationWithHole(int difficultyLevel) {
    final rand = Random();
    final equation = MathTestUtils.generateQuestion(difficultyLevel, 'Mixte');
    final answer = equation['answer'] as int;

    String question;
    List<String> choices = [];
    final holePosition = rand.nextInt(3);
    final parts = equation['question'].split(RegExp(r'[\+\-\×\÷= ]+'));
    final a = int.parse(parts[0]);
    final b = int.parse(parts[1]);
    final operator = equation['question'].contains('+')
        ? '+'
        : equation['question'].contains('-')
        ? '-'
        : equation['question'].contains('×')
        ? '×'
        : '÷';

    if (holePosition == 0) {
      question = '[ ? ] $operator $b = $answer';
      choices = _generateChoices(a.toString(), answer);
    } else if (holePosition == 1) {
      question = '$a $operator [ ? ] = $answer';
      choices = _generateChoices(b.toString(), answer);
    } else {
      question = '$a [ ? ] $b = $answer';
      choices = _generateOperatorChoices(operator);
    }

    return {
      'question': question,
      'answer': holePosition == 2 ? operator : (holePosition == 0 ? a.toString() : b.toString()),
      'choices': choices,
      'holePosition': holePosition,
    };
  }

  List<String> _generateChoices(String correctAnswer, int answer) {
    final rand = Random();
    final choices = <String>[correctAnswer];

    while (choices.length < 3) {
      int fakeAnswer = int.parse(correctAnswer) + rand.nextInt(10) - 5;
      if (!choices.contains(fakeAnswer.toString()) && fakeAnswer != answer) {
        choices.add(fakeAnswer.toString());
      }
    }

    choices.shuffle();
    return choices;
  }

  List<String> _generateOperatorChoices(String correctOperator) {
    final operators = ['+', '-', '×', '÷'];
    operators.remove(correctOperator);
    operators.shuffle();
    return [correctOperator, operators[0], operators[1]]..shuffle();
  }

  void submitAnswer(String selectedAnswer) {
    bool isCorrect = selectedAnswer == _correctAnswer;
    setState(() {
      if (isCorrect) {
        _correctAnswersInRow++;
        _pointsChange = 10 * _currentLevel;
        _points += _pointsChange;
        if (_correctAnswersInRow >= 3) {
          _currentLevel++;
          _correctAnswersInRow = 0;
          _pointsChange += 50;
          _points += 50;
        }
      } else {
        _correctAnswersInRow = 0;
        _pointsChange = -5;
        _points -= 5;
        if (_currentLevel > 1) {
          _currentLevel--;
        }
      }
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isCorrect = null;
      });
      generateQuestion();
    });
  }

  Future<void> _endTest() async {
    if (widget.isCompetition && widget.competitionId != null) {
      await _updateCompetitionData();
    }

    widget.profile.updateRecords(
        newRapidPoints: 0,
        newProblemPoints: 0,
        newEquationPoints: _points
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
    localData['equationTests'] = (localData['equationTests'] ?? 0) + 1;
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
          backgroundColor: Color(0xFF564560),
          title: Text(title, style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
          content: Text(message, style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
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

  Future<void> _showStartDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF564560),
          title: Text('Prêt à commencer ?', style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Lorsque vous commencerez, vous aurez 60 secondes pour répondre à un maximum de questions.',
                    style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
                Text('Bonne chance !', style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Commencer', style: TextStyle(color: Colors.white, fontFamily: 'PixelFont')),
              onPressed: () {
                Navigator.of(context).pop();
                if (!hasTestStarted) {
                  _incrementEquationTests();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _incrementEquationTests() async {
    if (widget.isCompetition && widget.competitionId != null) {
      var participantRef = FirebaseFirestore.instance
          .collection('competitions')
          .doc(widget.competitionId)
          .collection('participants')
          .doc(widget.profile.id);

      if (await ConnectivityManager().isConnected()) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          var snapshot = await transaction.get(participantRef);
          if (!snapshot.exists) {
            throw Exception("Participant does not exist!");
          }

          int newEquationTests = (snapshot.data()!['equationTests'] ?? 0) + 1;

          transaction.update(participantRef, {
            'equationTests': newEquationTests,
          });

          hasTestStarted = true;
        });
      } else {
        hasTestStarted = true;
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF564560),
      appBar: GameAppBar(points: _points, lastChange: _pointsChange),
      body: SafeArea(
        child: Column(
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
              child: Center(
                child: ArcadeConsole(
                  question: _currentQuestion,
                  choices: _answerChoices,
                  onAnswer: submitAnswer,
                  isCorrect: _isCorrect,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
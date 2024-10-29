import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/dialog_manager.dart';
import 'package:mathosproject/screens/problem_mode_screen.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';
import 'package:mathosproject/widgets/arcade_console.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
import 'package:mathosproject/widgets/level_indicator.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/math_test_utils.dart';
import 'package:mathosproject/widgets/game_app_bar.dart';
import 'package:mathosproject/user_preferences.dart';
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
  late int _initialRecord;  // Nouveau
  late int _currentLevel;
  late int _correctAnswersInRow;
  late int _points;
  late int _pointsChange;
  late String _currentQuestion;
  late String _correctAnswer;
  late List<String> _answerChoices;
  late int _holePosition;
  bool _hasStarted = false;
  bool _isGameOver = false;
  bool _isLoading = false;
  bool? _isCorrect;
  DateTime? _gameStartTime;
  final GlobalKey<CountdownTimerState> _countdownKey = GlobalKey<CountdownTimerState>();

  @override
  void initState() {
    super.initState();
    _currentLevel = 1;
    _correctAnswersInRow = 0;
    _currentQuestion = "";
    _answerChoices = [];
    _points = 0;
    _pointsChange = 0;
    _initializeGame();
    _initialRecord = widget.profile.equationTestRecord;  // Stocke le record initial

  }

  Future<void> _initializeGame() async {
    if (widget.isCompetition && widget.competitionId != null) {
      setState(() => _hasStarted = true);
      await _incrementGameCount();
      _gameStartTime = DateTime.now();
    }
    generateQuestion();
  }

  Future<void> _incrementGameCount() async {
    try {
      var localData = await HiveDataManager.getData<Map<String, dynamic>>(
          'competitionParticipants_${widget.competitionId}',
          widget.profile.id) ?? {};

      localData['name'] = widget.profile.name;
      localData['equationTests'] = (localData['equationTests'] ?? 0) + 1;
      localData['flag'] = widget.profile.flag;

      await HiveDataManager.saveData(
          'competitionParticipants_${widget.competitionId}',
          widget.profile.id,
          localData
      );

      if (await ConnectivityManager().isConnected()) {
        await FirebaseFirestore.instance
            .collection('competitions')
            .doc(widget.competitionId)
            .collection('participants')
            .doc(widget.profile.id)
            .set(localData, SetOptions(merge: true));
      }
    } catch (e) {
      print('Erreur lors de l\'incrémentation du compteur de parties: $e');
    }
  }

  Map<String, dynamic> _generateEquationWithHole(int difficultyLevel) {
    final rand = Random();
    final equation = MathTestUtils.generateQuestion(difficultyLevel, 'Mixte');
    final answer = equation['answer'] as int;

    // Si on obtient une équation avec 0 / x = 0, on en génère une nouvelle
    if (equation['question'].contains('÷') &&
        equation['question'].startsWith('0') &&
        answer == 0) {
      return _generateEquationWithHole(difficultyLevel);
    }



    String question;
    List<String> choices = [];
    final holePosition = rand.nextInt(3); // 0: premier nombre, 1: deuxième, 2: opérateur

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

    // Si on a une division et que a est 0, on génère une nouvelle équation
    if (operator == '÷' && a == 0) {
      return _generateEquationWithHole(difficultyLevel);
    }

    if (a == 0 && b == 0 && answer == 0) {
      return _generateEquationWithHole(difficultyLevel);
    }


    if (holePosition == 0) {
      question = '[ ? ] $operator $b = $answer';
      choices = _generateChoices(a.toString(), answer);
    } else if (holePosition == 1) {
      question = '$a $operator [ ? ] = $answer';
      choices = _generateChoices(b.toString(), answer);
    } else {
      question = '$a [ ? ] $b = $answer';
      if (_isAmbiguousOperator(a, b, answer)) {
        return _generateEquationWithHole(difficultyLevel);
      }
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

  bool _isAmbiguousOperator(int a, int b, int result) {
    int addition = a + b;
    int subtraction = a - b;
    int multiplication = a * b;
    double division = (b != 0) ? a / b : double.infinity;

    int countValidOperators = 0;
    if (addition == result) countValidOperators++;
    if (subtraction == result) countValidOperators++;
    if (multiplication == result) countValidOperators++;
    if (division == result) countValidOperators++;

    return countValidOperators > 1;
  }

  void generateQuestion() {
    if (_isGameOver) return;

    final result = _generateEquationWithHole(_currentLevel);
    setState(() {
      _currentQuestion = result['question'];
      _correctAnswer = result['answer'];
      _answerChoices = result['choices'];
      _holePosition = result['holePosition'];
      _isCorrect = null;
    });
  }

  void submitAnswer(String selectedAnswer) {
    bool isCorrect = selectedAnswer == _correctAnswer;
    setState(() {
      _isCorrect = isCorrect;
      if (isCorrect) {
        _correctAnswersInRow++;
        _pointsChange = 10 * _currentLevel;
        _points += _pointsChange;
        if (_correctAnswersInRow >= 3) {
          _currentLevel = _currentLevel < 10 ? _currentLevel + 1 : 10;
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

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _isCorrect = null;
      });
      generateQuestion();
    });
  }

  Future<void> _updateCompetitionData() async {
    if (!widget.isCompetition || widget.competitionId == null) return;

    try {
      var localData = await HiveDataManager.getData<Map<String, dynamic>>(
          'competitionParticipants_${widget.competitionId}',
          widget.profile.id) ?? {};

      Map<String, dynamic> updatedData = {
        'name': widget.profile.name,
        'flag': widget.profile.flag,
        'equationTests': localData['equationTests'] ?? 1,
        'rapidTests': localData['rapidTests'] ?? 0,
        'ProblemTests': localData['ProblemTests'] ?? 0,
        'totalPoints': (localData['totalPoints'] ?? 0) + _points,
        'lastUpdated': DateTime.now().toIso8601String(),
        'gameStartTime': _gameStartTime?.toIso8601String(),
        'gameEndTime': DateTime.now().toIso8601String(),
      };

      if (_points > (localData['equationTestRecord'] ?? 0)) {
        updatedData['equationTestRecord'] = _points;
      } else {
        updatedData['equationTestRecord'] = localData['equationTestRecord'] ?? 0;
      }

      await HiveDataManager.saveData(
          'competitionParticipants_${widget.competitionId}',
          widget.profile.id,
          updatedData
      );

      if (await ConnectivityManager().isConnected()) {
        DocumentReference participantRef = FirebaseFirestore.instance
            .collection('competitions')
            .doc(widget.competitionId)
            .collection('participants')
            .doc(widget.profile.id);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(participantRef);

          if (!snapshot.exists) {
            transaction.set(participantRef, updatedData);
          } else {
            transaction.update(participantRef, updatedData);
          }
        });
      }

      if (_points > widget.profile.equationTestRecord) {
        widget.profile.equationTestRecord = _points;
        if (await ConnectivityManager().isConnected()) {
          await UserPreferences.updateProfileInFirestore(widget.profile);
        } else {
          await UserPreferences.saveProfileLocally(widget.profile);
        }
      }
    } catch (e) {
      print('Erreur lors de la mise à jour des données de compétition: $e');
    }
  }

  Future<void> _endTest() async {
    if (_isGameOver) return;

    setState(() {
      _isGameOver = true;
    });

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

    if (await widget.profile.isOnline()) {
      await UserPreferences.updateProfileInFirestore(widget.profile);
    } else {
      await widget.profile.saveToLocalStorage();
    }
  }

  void _showEndGamePopup() {
    print("Record initial : $_initialRecord");
    print("Points actuels : $_points");

    String title;
    String message;

    // Cas d'une première partie
    if (_initialRecord == 0) {
      title = "🎮 Première Partie !";
      message = "Bienvenue dans l'aventure ! Vous venez d'établir votre score de référence avec $_points points. "
          "C'est un excellent début ! Voyons jusqu'où vous pourrez aller...";
    }
    // Cas d'un nouveau record
    else if (_points > _initialRecord) {
      int improvement = _points - _initialRecord;
      title = "🎉 NOUVEAU RECORD ! 🎉";
      message = "INCROYABLE ! Vous avez pulvérisé votre record personnel de $improvement points ! "
          "Votre nouveau record est maintenant de $_points points. Vous êtes en progression constante !";
    }
    // Autres cas (égalité ou score inférieur)
    else {
      double percentageOfRecord = (_points / _initialRecord) * 100;

      if (percentageOfRecord >= 90) {
        title = "Presque !";
        message = "Vous y étiez presque ! Avec $_points points, vous n'êtes qu'à ${(_initialRecord - _points)} "
            "points de votre record. Ne lâchez rien !";
      } else if (percentageOfRecord >= 75) {
        title = "Belle Performance !";
        message = "Bon score ! Vous vous rapprochez de votre record personnel de $_initialRecord points. "
            "Continuez sur cette lancée !";
      } else if (percentageOfRecord >= 50) {
        title = "Bien joué !";
        message = "Vous progressez bien ! Votre record de $_initialRecord points n'est pas si loin. "
            "Encore un peu d'entraînement et vous y arriverez !";
      } else {
        title = "Continuez vos efforts !";
        message = "N'abandonnez pas ! Chaque partie vous rapproche de votre record de $_initialRecord points. "
            "La pratique fait la perfection !";
      }
    }

    DialogManager.showCustomDialog(
      context: context,
      title: title,
      content: message,
      confirmText: 'Continuer',
      cancelText: '',
      onConfirm: () {
        Navigator.of(context).pop();
      },
    );
  }



  Future<bool> _handleBackPress() async {
    if (!_hasStarted || _isGameOver) return true;

    _countdownKey.currentState?.pauseTimer();

    bool shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF564560),
          title: Text(
            'Abandonner la partie ?',
            style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont', fontSize: 20),
          ),
          content: Text(
            'Cette partie sera comptée comme perdue et ne pourra pas être rejouée.',
            style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Continuer la partie',
                style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont', fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Abandonner',
                style: TextStyle(color: Colors.red, fontFamily: 'PixelFont', fontSize: 16),
              ),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                  _isGameOver = true;
                });

                // Mettre à jour les points gagnés avant l'abandon
                if (widget.isCompetition && widget.competitionId != null) {
                  await _updateCompetitionData();
                }

                setState(() {
                  _isLoading = false;
                });

                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;

    if (!shouldPop) {
      _countdownKey.currentState?.resumeTimer();
    }

    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
          appBar: GameAppBar(
            points: _points,
            lastChange: _pointsChange,
            isInGame: _hasStarted && !_isGameOver,
            onBackPressed: () async {
              bool shouldExit = await _handleBackPress();
              if (shouldExit) {
                Navigator.of(context).pop();
              }
            },
          ),
          body: Stack(
              children: [
          Positioned.fill(
          child: Container(color: Color(0xFF564560)),
    ),Column(
                  children: [
                    SizedBox(height: 20),
                    LevelIndicator(currentLevel: _currentLevel, maxLevel: 10),
                    SizedBox(height: 20),
                    CountdownTimer(
                      key: _countdownKey,
                      duration: 61,
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
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.yellow,
                      ),
                    ),
                  ),
              ],
          ),
      ),
    );
  }
}
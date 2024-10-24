import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mathosproject/dialog_manager.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/widgets/RetroCalculator.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
import 'package:mathosproject/widgets/game_app_bar.dart';
import 'package:mathosproject/widgets/level_indicator.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProblemModeScreen extends StatefulWidget {
  final AppUser profile;
  final bool isCompetition;
  final String? competitionId;

  ProblemModeScreen({
    required this.profile,
    this.isCompetition = false,
    this.competitionId,
  });

  @override
  _ProblemModeScreenState createState() => _ProblemModeScreenState();
}

class _ProblemModeScreenState extends State<ProblemModeScreen> {
  late int _currentLevel;
  late int _correctAnswersInRow;
  late int _points;
  late int _pointsChange;
  late String _currentQuestion;
  late String _currentAnswer;
  late TextEditingController _answerController;
  bool _isAnswerCorrect = false;
  bool _isSkipped = false;
  bool _hasStarted = false;
  bool _isGameOver = false;
  DateTime? _gameStartTime;
  bool _isLoading = false;
  final GlobalKey<CountdownTimerState> _countdownKey = GlobalKey<CountdownTimerState>();

  @override
  void initState() {
    super.initState();
    _currentLevel = 1;
    _correctAnswersInRow = 0;
    _currentQuestion = "";  // Initialisation de la variable
    _points = 0;
    _pointsChange = 0;
    _answerController = TextEditingController();
    _initializeGame();
    _answerController.addListener(_checkAnswer);
  }

  Future<void> _initializeGame() async {
    if (widget.isCompetition && widget.competitionId != null) {
      await _incrementGameCount();
      setState(() {
        _hasStarted = true;
        _gameStartTime = DateTime.now();
      });
    }
    generateQuestion();
  }

  Future<void> _incrementGameCount() async {
    try {
      var localData = await HiveDataManager.getData<Map<String, dynamic>>(
          'competitionParticipants_${widget.competitionId}',
          widget.profile.id) ?? {};

      localData['name'] = widget.profile.name;
      localData['ProblemTests'] = (localData['ProblemTests'] ?? 0) + 1;
      localData['flag'] = widget.profile.flag;
      localData['lastGameStarted'] = DateTime.now().toIso8601String();

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

  @override
  void dispose() {
    _answerController.removeListener(_checkAnswer);
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_answerController.text.isNotEmpty && _currentAnswer.isNotEmpty) {
      if (_answerController.text.trim().toLowerCase() == _currentAnswer.trim().toLowerCase()) {
        _validateCorrectAnswer();
      }
    }
    setState(() {});
  }

  void _validateCorrectAnswer() {
    if (_isGameOver) return;

    setState(() {
      _isAnswerCorrect = true;
      _isSkipped = false;
      _correctAnswersInRow++;
      _pointsChange = 50 * _currentLevel;
      _points += _pointsChange;
      if (_correctAnswersInRow >= 3) {
        _currentLevel++;
        _correctAnswersInRow = 0;
        _pointsChange += 50;
        _points += 50;
      }
    });

    Future.delayed(Duration(milliseconds: 200), () {
      generateQuestion();
    });
  }

  void generateQuestion() {
    if (_isGameOver) return;

    loadProblemsFromAssets().then((problems) {
      List<dynamic> problemList;
      switch (_currentLevel) {
        case 1:
          problemList = problems["niveau1"];
          break;
        case 2:
          problemList = problems["niveau2"];
          break;
        case 3:
          problemList = problems["niveau3"];
          break;
        case 4:
          problemList = problems["niveau4"];
          break;
        case 5:
          problemList = problems["niveau5"];
          break;
        default:
          problemList = problems["niveau1"];
      }

      Random random = Random();
      var selectedProblem = problemList[random.nextInt(problemList.length)];

      setState(() {
        _currentQuestion = selectedProblem['question'];
        _currentAnswer = selectedProblem['reponse']?.toString() ?? "";
        _isAnswerCorrect = false;
        _isSkipped = false;
        _answerController.text = "";
      });
    });
  }

  Future<Map<String, dynamic>> loadProblemsFromAssets() async {
    String jsonString = await rootBundle.loadString('assets/problems_by_level.json');
    return json.decode(jsonString);
  }

  void skipQuestion() {
    if (_isGameOver) return;

    setState(() {
      _isSkipped = true;
      _isAnswerCorrect = false;
      _correctAnswersInRow = 0;
      _pointsChange = -100;
      _points += _pointsChange;
      if (_currentLevel > 1) {
        _currentLevel--;
      }
    });

    Future.delayed(Duration(milliseconds: 300), () {
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
        'ProblemTests': localData['ProblemTests'] ?? 1,
        'totalPoints': (localData['totalPoints'] ?? 0) + _points,
        'lastUpdated': DateTime.now().toIso8601String(),
        'gameStartTime': _gameStartTime?.toIso8601String(),
        'gameEndTime': DateTime.now().toIso8601String(),
      };

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
            Map<String, dynamic> existingData =
            snapshot.data() as Map<String, dynamic>;

            transaction.update(participantRef, updatedData);
          }
        });
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
        newProblemPoints: _points,
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

    DialogManager.showCustomDialog(
      context: context,
      title: title,
      content: message,
      confirmText: 'OK',
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

                await _updateCompetitionData();

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
            ),
            Column(
              children: [
                SizedBox(height: 20),
                LevelIndicator(currentLevel: _currentLevel, maxLevel: 5),
                SizedBox(height: 20),
                CountdownTimer(
                  key: _countdownKey,
                  duration: 121,
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
                          _answerController.text = _answerController.text.substring(
                              0,
                              _answerController.text.length - 1
                          );
                        });
                      }
                    },
                    isCorrectAnswer: _isAnswerCorrect,
                    isSkipped: _isSkipped,
                    isProblemMode: true,
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.yellow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

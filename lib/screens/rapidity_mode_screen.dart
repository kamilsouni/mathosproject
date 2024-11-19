import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/dialog_manager.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/widgets/RetroCalculator.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
import 'package:mathosproject/widgets/level_indicator.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/math_test_utils.dart';
import 'package:mathosproject/widgets/game_app_bar.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/screens/end_game_analysis_screen.dart';

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

class _RapidityModeScreenState extends State<RapidityModeScreen> {
  late int _initialRecord;
  late int _currentLevel;
  late int _correctAnswersInRow;
  late int _points;
  late int _pointsChange;
  late String _currentQuestion;
  late int _currentAnswer;
  late TextEditingController _answerController;
  bool _isAnswerCorrect = false;
  bool _isSkipped = false;
  bool _hasStarted = false;
  bool _isGameOver = false;
  DateTime? _gameStartTime;
  bool _isLoading = false;
  final GlobalKey<CountdownTimerState> _countdownKey = GlobalKey<CountdownTimerState>();
  final List<Map<String, dynamic>> _operationsHistory = [];

  @override
  void initState() {
    super.initState();
    _currentLevel = 1;
    _correctAnswersInRow = 0;
    _points = 0;
    _currentQuestion = "";
    _pointsChange = 0;
    _answerController = TextEditingController();
    _initializeGame();
    _answerController.addListener(_checkAnswer);
    _initialRecord = widget.profile.rapidTestRecord;
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
      localData['rapidTests'] = (localData['rapidTests'] ?? 0) + 1;
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
    if (_answerController.text.isNotEmpty) {
      int? userAnswer = int.tryParse(_answerController.text);
      if (userAnswer != null && userAnswer == _currentAnswer) {
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
      _pointsChange = 10 * _currentLevel;
      _points += _pointsChange;
      if (_correctAnswersInRow >= 3) {
        _currentLevel++;
        _correctAnswersInRow = 0;
        _pointsChange += 50;
        _points += 50;
      }
      _operationsHistory.add({
        'question': _currentQuestion,
        'answer': _currentAnswer,
        'isCorrect': true,
      });
    });

    Future.delayed(Duration(milliseconds: 200), () {
      generateQuestion();
    });
  }

  void generateQuestion() {
    if (_isGameOver) return;

    final result = MathTestUtils.generateQuestion(_currentLevel, 'Mixte');
    setState(() {
      _currentQuestion = result['question'];
      _currentAnswer = result['answer'];
      _isAnswerCorrect = false;
      _isSkipped = false;
      _answerController.text = "";
    });
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
      _operationsHistory.add({
        'question': _currentQuestion,
        'answer': _currentAnswer,
        'isCorrect': false,
      });
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
        'rapidTests': localData['rapidTests'] ?? 1,
        'ProblemTests': localData['ProblemTests'] ?? 0,
        'equationTests': localData['equationTests'] ?? 0,
        'totalPoints': (localData['totalPoints'] ?? 0) + _points,
        'lastUpdated': DateTime.now().toIso8601String(),
        'gameStartTime': _gameStartTime?.toIso8601String(),
        'gameEndTime': DateTime.now().toIso8601String(),
      };

      if (_points > (localData['rapidTestRecord'] ?? 0)) {
        updatedData['rapidTestRecord'] = _points;
      } else {
        updatedData['rapidTestRecord'] = localData['rapidTestRecord'] ?? 0;
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
            Map<String, dynamic> existingData =
            snapshot.data() as Map<String, dynamic>;

            int currentRecord = existingData['rapidTestRecord'] ?? 0;
            if (_points > currentRecord) {
              updatedData['rapidTestRecord'] = _points;
            } else {
              updatedData['rapidTestRecord'] = currentRecord;
            }

            transaction.update(participantRef, updatedData);
          }
        });
      }

      if (_points > widget.profile.rapidTestRecord) {
        widget.profile.rapidTestRecord = _points;
        if (await ConnectivityManager().isConnected()) {
          await UserPreferences.updateProfileInFirestore(widget.profile);
        } else {
          await UserPreferences.saveProfileLocally(widget.profile);
        }
      }

    } catch (e) {
      print('Erreur lors de la mise à jour des données de compétition: $e');
      await HiveDataManager.saveData(
          'pendingUpdates_${widget.competitionId}',
          '${widget.profile.id}_${DateTime.now().millisecondsSinceEpoch}',
          {
            'type': 'rapidityUpdate',
            'data': {
              'userId': widget.profile.id,
              'points': _points,
              'timestamp': DateTime.now().toIso8601String(),
            }
          }
      );
    }
  }

// Dans RapidityModeScreen.dart, modifiez la méthode _endTest :

  Future<void> _endTest() async {
    if (_isGameOver) return;

    setState(() {
      _isGameOver = true;
    });

    if (widget.isCompetition && widget.competitionId != null) {
      await _updateCompetitionData();
    }

    widget.profile.updateRecords(
        newRapidPoints: _points,
        newProblemPoints: 0,
        newEquationPoints: 0
    );

    widget.profile.points += _points;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EndGameAnalysisScreen(
          score: _points,
          operationsHistory: _operationsHistory,
          initialRecord: _initialRecord,
          gameMode: 'rapid', // ou 'problem' ou 'equation' selon le mode
          isCompetition: widget.isCompetition,
          competitionId: widget.competitionId,
          profile: widget.profile, // Ajout du profile
        ),
      ),
    );

    Future.delayed(Duration.zero, () async {
      if (await widget.profile.isOnline()) {
        await UserPreferences.updateProfileInFirestore(widget.profile);
      } else {
        await widget.profile.saveToLocalStorage();
      }
    });
  }


  Future<bool> _handleBackPress() async {
    if (!_hasStarted || _isGameOver) return true;

    _countdownKey.currentState?.pauseTimer();

    bool? shouldPop = await DialogManager.showCustomDialogWithWidget<bool>(
      context: context,
      title: 'Abandonner la partie ?',
      contentWidget: Text(
        'Cette partie sera comptée comme perdue et ne pourra pas être rejouée.',
        style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 16),
      ),
      confirmText: 'Abandonner',
      onConfirm: () async {
        setState(() {
          _isLoading = true;
          _isGameOver = true;
        });

        if (widget.isCompetition && widget.competitionId != null) {
          await _updateCompetitionData();
        }

        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pop(true);
      },
      buttonColor: Colors.red, // Bouton rouge pour indiquer une action "négative"
    );

    if (shouldPop == null || !shouldPop) {
      _countdownKey.currentState?.resumeTimer();
    }

    return shouldPop ?? false;
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
                  key: _countdownKey,
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
                          _answerController.text = _answerController.text.substring(
                              0,
                              _answerController.text.length - 1
                          );
                        });
                      }
                    },
                    isCorrectAnswer: _isAnswerCorrect,
                    isSkipped: _isSkipped,
                    isRapidMode: true,
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

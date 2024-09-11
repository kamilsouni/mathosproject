import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/widgets/custom_keyboard.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
import 'package:mathosproject/widgets/level_indicator.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/math_test_utils.dart';
import 'package:mathosproject/widgets/game_app_bar.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';

class RapidityModeScreen extends StatefulWidget {
  final AppUser profile;
  final bool isCompetition;
  final String? competitionId;

  RapidityModeScreen({required this.profile, this.isCompetition = false, this.competitionId});

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
  late FocusNode _focusNode;

  bool hasTestStarted = false;

  @override
  void initState() {
    super.initState();
    _currentLevel = 1;
    _correctAnswersInRow = 0;
    _points = 0;
    _pointsChange = 0;
    _answerController = TextEditingController();
    _focusNode = FocusNode();
    generateQuestion();
    _answerController.addListener(_checkAnswer);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _showStartDialog(); // Affiche le dialogue de départ lorsque l'écran est ouvert
  }

  @override
  void dispose() {
    _answerController.removeListener(_checkAnswer);
    _answerController.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // L'application est en arrière-plan
      _showExitDialog();
    }
  }

  void _checkAnswer() {
    if (_answerController.text.isNotEmpty &&
        int.tryParse(_answerController.text) == _currentAnswer) {
      submitAnswer(true);
    }
  }

  void generateQuestion() {
    final result = MathTestUtils.generateQuestion(_currentLevel, 'Mixte');
    setState(() {
      _currentQuestion = result['question'];
      _currentAnswer = result['answer'];
      _answerController.text = "";
      _focusNode.requestFocus();
    });
  }

  void submitAnswer(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        _correctAnswersInRow++;
        _pointsChange = 10 * _currentLevel;
        _points += _pointsChange;
        if (_correctAnswersInRow >= 3) {
          _currentLevel++;
          _correctAnswersInRow = 0;
          _pointsChange += 50; // Bonus de points pour chaque niveau atteint
          _points += 50;
        }
      } else {
        _correctAnswersInRow = 0;
        _pointsChange = -5;
        _points -= 5; // Déduire des points pour chaque réponse incorrecte
        if (_currentLevel > 1) {
          _currentLevel--;
        }
      }
    });
    generateQuestion();
  }

  void _passQuestion() {
    setState(() {
      _correctAnswersInRow = 0;
      _pointsChange = -5;
      _points -= 5; // Déduire des points pour passer une question
      if (_currentLevel > 1) {
        _currentLevel--;
      }
    });
    generateQuestion();
  }

  void _showEndGamePopup(int points) {
    String message;
    String title;

    if (points > 1500) {
      title = "Félicitations !";
      message = "Wow ! Vous avez obtenu $points points 🎉. Vous êtes un vrai champion ! Continuez comme ça !";
    } else if (points > 1000) {
      title = "Excellent travail !";
      message = "Bravo, vous avez obtenu $points points 👍. Vous progressez très bien !";
    } else if (points > 500) {
      title = "Bien joué !";
      message = "Bon travail ! Vous avez obtenu $points points. Continuez à vous améliorer !";
    } else {
      title = "Continuez à essayer !";
      message = "Vous avez obtenu $points points. Ne vous découragez pas, vous pouvez faire encore mieux 💪.";
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Empêche de fermer le pop-up en appuyant ailleurs
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le pop-up
                Navigator.pop(context); // Retour à l'écran précédent (ou à la compétition)
              },
            ),
          ],
        );
      },
    );
  }

  void endTest() async {
    try {
      _showEndGamePopup(_points);

      if (widget.isCompetition && widget.competitionId != null) {
        var localData = await HiveDataManager.getData<Map<String, dynamic>>('competitionParticipants_${widget.competitionId}', widget.profile.id) ?? {};

        localData['name'] = widget.profile.name;
        localData['precisionTests'] = (localData['precisionTests'] ?? 0) + 1;
        localData['totalPoints'] = (localData['totalPoints'] ?? 0) + _points;
        localData['flag'] = widget.profile.flag;

        await HiveDataManager.saveData('competitionParticipants_${widget.competitionId}', widget.profile.id, localData);

        if (await ConnectivityManager().isConnected()) {
          await FirebaseFirestore.instance
              .collection('competitions')
              .doc(widget.competitionId)
              .collection('participants')
              .doc(widget.profile.id)
              .set(localData, SetOptions(merge: true));
        }
      }

      widget.profile.points += _points;
      widget.profile.updateRecords(newRapidPoints: 0, newPrecisionPoints: _points);

      await UserPreferences.saveProfile(widget.profile);

      // Forcer une mise à jour de l'écran de compétition
      Navigator.pop(context, true);  // Retourner true pour indiquer que des changements ont eu lieu

    } catch (e) {
      print('Error updating participant data: $e');
    }
  }

  Future<void> _showStartDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // L'utilisateur doit appuyer sur un bouton pour fermer le dialogue
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Prêt à commencer ?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Lorsque vous commencerez, vous aurez 60 secondes pour répondre à un maximum de questions.'),
                Text('Bonne chance !'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Commencer'),
              onPressed: () {
                Navigator.of(context).pop();
                if (!hasTestStarted) {
                  _incrementRapidTests(); // Incrémenter uniquement au début
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _incrementRapidTests() async {
    if (widget.isCompetition && widget.competitionId != null) {
      var localData = await HiveDataManager.getData<Map<String, dynamic>>('competitionParticipants_${widget.competitionId}', widget.profile.id) ?? {};

      localData['precisionTests'] = (localData['precisionTests'] ?? 0) + 1;

      await HiveDataManager.saveData('competitionParticipants_${widget.competitionId}', widget.profile.id, localData);

      if (await ConnectivityManager().isConnected()) {
        var participantRef = FirebaseFirestore.instance
            .collection('competitions')
            .doc(widget.competitionId)
            .collection('participants')
            .doc(widget.profile.id);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          var snapshot = await transaction.get(participantRef);
          if (!snapshot.exists) {
            throw Exception("Participant does not exist!");
          }

          int newPrecisionTests = (snapshot.data()!['precisionTests'] ?? 0) + 1;

          transaction.update(participantRef, {
            'precisionTests': newPrecisionTests,
          });
        });
      }

      // Marquer le test comme commencé
      hasTestStarted = true;
    }
  }

  Future<void> _showExitDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // L'utilisateur doit appuyer sur un bouton pour fermer le dialogue
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quitter l\'épreuve'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Si vous quittez maintenant, vous obtiendrez 0 point et l\'épreuve sera considérée comme terminée.'),
                Text('Voulez-vous vraiment quitter ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Quitter'),
              onPressed: () {
                _points = 0;
                endTest();
                Navigator.of(context).pop();
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

    return WillPopScope(
      onWillPop: () async {
        _showExitDialog();
        return false;  // Désactiver le bouton de retour
      },
      child: Scaffold(
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
            Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                LevelIndicator(currentLevel: _currentLevel, maxLevel: 10),
                SizedBox(height: screenHeight * 0.02),
                CountdownTimer(
                  duration: 60,
                  onCountdownComplete: endTest,
                  progressColor: Colors.green,
                  height: screenHeight * 0.02,
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  _currentQuestion,
                  style: TextStyle(
                      fontSize: screenHeight * 0.05, fontWeight: FontWeight.bold),
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
                            width: 2.0),
                      ),
                    ),
                    onSubmitted: (value) {
                      submitAnswer(int.tryParse(value) == _currentAnswer);
                      _focusNode.requestFocus();
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomKeyboard(
                controller: _answerController,
                onSubmit: _passQuestion,
                onDelete: () {
                  if (_answerController.text.isNotEmpty) {
                    setState(() {
                      _answerController.text = _answerController.text
                          .substring(0, _answerController.text.length - 1);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

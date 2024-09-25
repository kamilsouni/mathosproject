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

class _ProblemModeScreenState extends State<ProblemModeScreen> with WidgetsBindingObserver {
  late int _currentLevel;
  late int _correctAnswersInRow;
  late int _points;
  late int _pointsChange;
  late String _currentQuestion;
  late String _currentAnswer;
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
    _currentQuestion = "Chargement...";
    _currentAnswer = "";
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

  // Charger les problèmes depuis le fichier JSON
  Future<Map<String, dynamic>> loadProblemsFromAssets() async {
    String jsonString = await rootBundle.loadString('assets/problems_by_level.json');
    return json.decode(jsonString);
  }

  // Générer une question à partir du fichier JSON
  Future<void> generateQuestion() async {
    var problems = await loadProblemsFromAssets();
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
  }

  // Valider la réponse
  void _checkAnswer() {
    if (_answerController.text.isNotEmpty && _currentAnswer.isNotEmpty) {
      if (_answerController.text.trim().toLowerCase() == _currentAnswer.trim().toLowerCase()) {
        _validateCorrectAnswer();
      }
    }
    setState(() {});
  }



  void _validateCorrectAnswer() {
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

    Future.delayed(Duration(milliseconds: 300), () {
      generateQuestion();
    });
  }

  void skipQuestion() {
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

  Future<void> _endTest() async {
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

  Future<void> _updateCompetitionData() async {
    var localData = await HiveDataManager.getData<Map<String, dynamic>>(
        'competitionParticipants_${widget.competitionId}', widget.profile.id) ?? {};

    localData['name'] = widget.profile.name;
    localData['ProblemTests'] = (localData['ProblemTests'] ?? 0) + 1;
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

    // Utilisation du DialogManager pour afficher la popup de fin de jeu
    DialogManager.showCustomDialog(
      context: context,
      title: title,  // Titre dynamique en fonction des points
      content: message,  // Message dynamique en fonction des points
      confirmText: 'OK',  // Texte du bouton de confirmation
      cancelText: '',  // Pas de bouton "Annuler"
      onConfirm: () {
        Navigator.of(context).pop();  // Fermer le dialogue
        Navigator.of(context).pop(true);  // Fermer l'écran du jeu ou retourner à l'écran précédent
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
              LevelIndicator(currentLevel: _currentLevel, maxLevel: 5),
              SizedBox(height: 20),
              CountdownTimer(
                duration: 120,
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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/screens/precision_mode_screen.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';
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
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late int _currentLevel;
  late int _correctAnswersInRow;
  late int _points;
  late int _pointsChange;
  late String _currentQuestion;
  late String _correctAnswer;
  late List<String> _answerChoices;
  late int _holePosition;
  bool hasTestStarted = false;

  List<AnimationController>? _cardAnimationControllers;
  List<Animation<double>>? _cardAnimations;

  @override
  void initState() {
    super.initState();
    _currentLevel = 1;
    _correctAnswersInRow = 0;
    _points = 0;
    _pointsChange = 0;
    WidgetsBinding.instance.addObserver(this);
    _initCardAnimations();
    generateQuestion();
    _showStartDialog();
  }

  void _initCardAnimations() {
    _cardAnimationControllers = List.generate(
      3,
          (index) => AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    _cardAnimations = _cardAnimationControllers!
        .map((controller) => Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    ))
        .toList();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (_cardAnimationControllers != null) {
      for (var controller in _cardAnimationControllers!) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _showExitDialog();
    }
  }

  void generateQuestion() {
    final result = _generateEquationWithHole(_currentLevel);
    setState(() {
      _currentQuestion = result['question'];
      _correctAnswer = result['answer'];
      _answerChoices = result['choices'];
      _holePosition = result['holePosition'];
    });

    if (_cardAnimationControllers != null) {
      for (var controller in _cardAnimationControllers!) {
        controller.reset();
        controller.forward();
      }
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
      question = '___ $operator $b = $answer';
      choices = _generateChoices(a.toString(), answer);
    } else if (holePosition == 1) {
      question = '$a $operator ___ = $answer';
      choices = _generateChoices(b.toString(), answer);
    } else {
      question = '$a ___ $b = $answer';
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
    generateQuestion();
  }

  Future<void> _endTest() async {
    // Vérifie si c'est une compétition et met à jour les données de la compétition
    if (widget.isCompetition && widget.competitionId != null) {
      await _updateCompetitionData();
    }

    // Mise à jour des records locaux
    widget.profile.updateRecords(
        newRapidPoints: 0,
        newPrecisionPoints: 0,
        newEquationPoints: _points
    );

    // Incrémentation des points dans le profil utilisateur
    widget.profile.points += _points;

    // Affiche immédiatement la fenêtre de fin de partie
    _showEndGamePopup();

    // Synchroniser les données en arrière-plan
    Future.delayed(Duration.zero, () async {
      if (await widget.profile.isOnline()) {
        // Si l'utilisateur est en ligne, synchroniser avec Firebase
        await UserPreferences.updateProfileInFirestore(widget.profile);
      } else {
        // Si l'utilisateur est hors ligne, sauvegarder localement
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

  Future<void> _showStartDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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

  Future<void> _showExitDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                _endTest();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEquationDisplay(String question) {
    List<Widget> equationParts = [];
    var splitQuestion = question.split('___');

    for (int i = 0; i < splitQuestion.length; i++) {
      equationParts.add(
          Text(
            splitQuestion[i],
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )
      );

      if (i < splitQuestion.length - 1) {
        equationParts.add(
            Container(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: CrystalPainter(),
              ),
            )
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: equationParts,
    );
  }

  Widget _buildAnswerCard(String choice, int index) {
    return AnimatedBuilder(
      animation: _cardAnimations?[index] ?? AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        final animationValue = _cardAnimations?[index]?.value ?? 1.0;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(pi * (1 - animationValue)),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => submitAnswer(choice),
            child: Container(
              width: 120,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFFF0E6D2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF8B0000), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TarotBackgroundPainter(),
                    ),
                  ),
                  Center(
                    child: Text(
                      choice,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),fontFamily: 'Serif',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
        return false;
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
                  onCountdownComplete: _endTest,
                  progressColor: Colors.green,
                  height: screenHeight * 0.02,
                ),
                SizedBox(height: screenHeight * 0.05),
                _buildEquationDisplay(_currentQuestion),
                SizedBox(height: screenHeight * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) {
                    return _buildAnswerCard(_answerChoices[index], index);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 5;
    double startX = 0;
    final space = dashSpace + dashWidth;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += space;
    }

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += space;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TarotBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF8B0000).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (int i = 0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }

    final decorPaint = Paint()
      ..color = Color(0xFF8B0000).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 30, decorPaint);
    canvas.drawRect(Rect.fromLTWH(10, 10, 20, 20), decorPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 30, size.height - 30, 20, 20), decorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CrystalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF8B0000)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width * 0.7, size.height);
    path.lineTo(size.width * 0.3, size.height);
    path.lineTo(0, size.height * 0.4);
    path.close();

    canvas.drawPath(path, paint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.3, size.height * 0.2);
    highlightPath.lineTo(size.width * 0.7, size.height * 0.2);
    highlightPath.lineTo(size.width * 0.5, size.height * 0.5);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
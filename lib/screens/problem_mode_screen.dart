import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/widgets/game_app_bar.dart';
import 'package:mathosproject/widgets/custom_keyboard.dart';
import 'package:mathosproject/widgets/countdown_timer.dart';
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
  late int _points;
  late int _pointsChange;
  late String _currentQuestion;
  late int _currentAnswer;
  late int _currentLevel;
  late TextEditingController _answerController;
  late FocusNode _focusNode;
  int _correctAnswersInRow = 0;  // Initialise la variable

  @override
  void initState() {
    super.initState();
    _points = 0;
    _pointsChange = 0;
    _currentLevel = 1; // Niveau initial
    _answerController = TextEditingController();
    _focusNode = FocusNode();
    generateQuestion();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }




  Map<String, dynamic> generateScenarioForLevel(int level) {
    Random random = Random();

    // Listes mises à jour
    List<String> industries = [
      "une entreprise de fabrication de jouets",
      "une usine automobile",
      "une entreprise de logiciels",
      "une entreprise de mode",
      "une usine alimentaire",
      "une start-up technologique",
      "un laboratoire pharmaceutique",
      "une compagnie aéronautique",
      "une chaîne de supermarchés",
      "une société de transport maritime",
      "une entreprise de construction",
      "une entreprise de mobilier",
      "une entreprise de boissons",
      "une entreprise de télécommunications",
      "une société énergétique",
      "une banque d'investissement",
      "une entreprise minière",
      "un cabinet de conseil",
      "un hôpital privé",
      "une société de gestion d'actifs"
    ];

    List<String> roles = [
      "directeur financier",
      "responsable des ventes",
      "chef de projet",
      "directeur de production",
      "directeur marketing",
      "responsable des ressources humaines",
      "PDG",
      "directeur des opérations",
      "responsable de la chaîne logistique",
      "chef de produit",
      "directeur informatique",
      "consultant stratégique",
      "analyste financier",
      "gestionnaire de portefeuille",
      "responsable des achats",
      "directeur R&D"
    ];

    List<String> objectives = [
      "réduire les coûts",
      "augmenter les ventes",
      "optimiser le budget",
      "faire croître les profits",
      "réduire les déchets",
      "améliorer la productivité",
      "augmenter la marge opérationnelle",
      "réduire les délais de production",
      "optimiser la gestion des stocks",
      "améliorer la satisfaction client"
    ];

    List<String> events = [
      "une récession économique",
      "une période de forte demande",
      "une expansion internationale",
      "le lancement d'un nouveau produit",
      "une crise d'approvisionnement",
      "une fusion avec une autre entreprise",
      "de nouvelles régulations environnementales",
      "l'arrivée d'un nouveau concurrent",
      "une augmentation des coûts des matières premières"
    ];

    // Génération aléatoire des éléments
    String industry = industries[random.nextInt(industries.length)];
    String role = roles[random.nextInt(roles.length)];
    String objective = objectives[random.nextInt(objectives.length)];
    String event = events[random.nextInt(events.length)];

    // Vérification de la cohérence du contexte
    if (objective.contains("réduire") && event.contains("forte demande")) {
      event = events.where((e) => !e.contains("forte demande")).toList()[random.nextInt(events.length)];
    }

    if (objective.contains("augmenter") && event.contains("récession")) {
      objective = objectives.where((o) => !o.contains("augmenter")).toList()[random.nextInt(objectives.length)];
    }

    // Génération du pourcentage et du budget
    double percentage;
    int budget;
    switch (level) {
      case 1:
        percentage = [5.0, 10.0].elementAt(random.nextInt(2));
        budget = [100, 200, 500].elementAt(random.nextInt(3));
        break;
      case 2:
        percentage = [5.0, 10.0, 15.0].elementAt(random.nextInt(3));
        budget = [300, 400, 600].elementAt(random.nextInt(3));
        break;
      case 3:
        percentage = [10.0, 15.0, 20.0].elementAt(random.nextInt(3));
        budget = [700, 800, 900].elementAt(random.nextInt(3));
        break;
      case 4:
        percentage = [15.0, 20.0, 25.0].elementAt(random.nextInt(3));
        budget = [1000, 1500, 2000].elementAt(random.nextInt(3));
        break;
      case 5:
        percentage = [20.0, 25.0, 30.0].elementAt(random.nextInt(3));
        budget = [2500, 3000, 3500].elementAt(random.nextInt(3));
        break;
      case 6:
        percentage = [25.0, 30.0, 35.0].elementAt(random.nextInt(3));
        budget = [4000, 4500, 5000].elementAt(random.nextInt(3));
        break;
      case 7:
        percentage = [30.0, 35.0, 40.0].elementAt(random.nextInt(3));
        budget = [6000, 7000, 8000].elementAt(random.nextInt(3));
        break;
      case 8:
        percentage = [35.0, 40.0, 45.0].elementAt(random.nextInt(3));
        budget = [9000, 10000, 12000].elementAt(random.nextInt(3));
        break;
      case 9:
        percentage = [40.0, 45.0, 50.0].elementAt(random.nextInt(3));
        budget = [15000, 20000, 25000].elementAt(random.nextInt(3));
        break;
      case 10:
        percentage = [45.0, 50.0, 55.0].elementAt(random.nextInt(3));
        budget = [30000, 40000, 50000].elementAt(random.nextInt(3));
        break;
      default:
        percentage = [5.0, 10.0].elementAt(random.nextInt(2));
        budget = [100, 200, 500].elementAt(random.nextInt(3));
        break;
    }

    // Calcul de la réponse en fonction de l'augmentation ou réduction
    double finalAmount;
    String operation;
    if (random.nextBool()) {
      finalAmount = budget * (1 + percentage / 100);
      operation = "augmentation";
    } else {
      finalAmount = budget * (1 - percentage / 100);
      operation = "réduction";
    }

    // Vérification que le résultat est bien un entier
    finalAmount = finalAmount.roundToDouble();

    // Retour du scénario
    return {
      'scenario': "En tant que $role dans $industry, vous devez $objective à cause de $event. Le budget initial est de $budget €. Que sera le budget après une $operation de $percentage% ?",
      'answer': finalAmount.toInt()
    };
  }











  void generateQuestion() {
    final result = generateScenarioForLevel(_currentLevel);
    setState(() {
      _currentQuestion = result['scenario'];
      _currentAnswer = result['answer'];
      _answerController.text = "";
      _focusNode.requestFocus();
    });
  }




  void submitAnswer() {
    bool isCorrect = _answerController.text == _currentAnswer.toString();
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
        newProblemPoints: _points,
        newEquationPoints: 0
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
    print("Popup de fin de partie affiché");  // Log pour débogage
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        _showExitDialog();
        return false;
      },
      child: Scaffold(
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
            Column(
              children: [
                SizedBox(height: screenHeight * 0.15), // Ensure enough space below the app bar

                CountdownTimer(
                  duration: 60,
                  onCountdownComplete: _endTest,
                  textStyle: TextStyle(
                    fontSize: screenHeight * 0.03, // Adapt text size for countdown
                  ),
                  progressColor: Colors.black.withOpacity(0.7),
                  height: screenHeight * 0.02,
                ),

                SizedBox(height: screenHeight * 0.03), // Adjust space after timer

                // Main content with adaptable text size
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double availableHeight = constraints.maxHeight;
                      double availableWidth = constraints.maxWidth;

                      // Dynamically calculate the font size based on available space
                      double questionFontSize = availableHeight * 0.06; // Make this dynamic based on height
                      double inputFontSize = availableHeight * 0.05;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: availableWidth * 0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _currentQuestion,
                                style: TextStyle(
                                  fontSize: questionFontSize, // Dynamically set font size
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: availableHeight * 0.02), // Adjust space

                            // Input field for answer
                            Container(
                              width: availableWidth * 0.6,
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _answerController,
                                keyboardType: TextInputType.none,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: inputFontSize, // Adapt input text size
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: availableHeight * 0.01, // Adapt padding
                                  ),
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
                              ),
                            ),
                            SizedBox(height: availableHeight * 0.02), // Adjust space

                            // Submit button
                            ElevatedButton(
                              onPressed: submitAnswer,
                              child: Text(
                                'Valider',
                                style: TextStyle(
                                  fontSize: availableHeight * 0.03, // Adapt button text size
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.withOpacity(0.7),
                                padding: EdgeInsets.symmetric(
                                  horizontal: availableWidth * 0.15,
                                  vertical: availableHeight * 0.015, // Adapt button size
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Custom Keyboard
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
          ],
        ),
      ),
    );
  }




  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quitter l\'épreuve'),
          content: Text('Êtes-vous sûr de vouloir quitter ? Votre progression ne sera pas sauvegardée.'),
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
                Navigator.of(context).pop();
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}

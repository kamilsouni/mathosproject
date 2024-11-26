import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:mathosproject/screens/equations_mode_screen.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/problem_mode_screen.dart';
import 'package:mathosproject/screens/progression_mode_screen.dart';
import 'package:mathosproject/screens/progression_screen.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';

class EndGameAnalysisScreen extends StatefulWidget {
  final int score;
  final List<Map<String, dynamic>> operationsHistory;
  final int initialRecord;
  final String gameMode;
  final bool isCompetition;
  final String? competitionId;
  final AppUser profile;
  final int level;
  final bool isProgressionMode;
  final String operationType;
  final bool isQuickValidation;
  final bool hasValidatedOperator;
  final int totalQuestionsNeeded;

  EndGameAnalysisScreen({
    required this.score,
    required this.operationsHistory,
    required this.initialRecord,
    required this.gameMode,
    required this.isCompetition,
    this.competitionId,
    required this.profile,
    this.level = 1,
    this.isProgressionMode = false,
    this.operationType = '',
    this.isQuickValidation = false,
    this.hasValidatedOperator = false,
    this.totalQuestionsNeeded = 30,
  });

  @override
  _EndGameAnalysisScreenState createState() => _EndGameAnalysisScreenState();
}

class _EndGameAnalysisScreenState extends State<EndGameAnalysisScreen> {
  final _scrollController = ScrollController();
  late ConfettiController _confettiController;
  bool _showConfetti = false;
  bool _operationsDisplayComplete = false;
  final ValueNotifier<int> _currentOperationIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF564560),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _startOperationsAnimation();
  }

  void _startOperationsAnimation() async {
    for (int i = 0; i < widget.operationsHistory.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      _currentOperationIndex.value = i;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 50),
          curve: Curves.easeOut,
        );
      }
    }
    setState(() {
      _operationsDisplayComplete = true;
      if (widget.hasValidatedOperator || widget.isQuickValidation) {
        _showConfetti = true;
        _confettiController.play();
      }
    });
  }

  // Obtention du titre du mode
  String _getModeTitle() {
    switch (widget.gameMode) {
      case 'rapid':
        return 'Mode Rapidité';
      case 'problem':
        return 'Mode Problème';
      case 'equation':
        return 'Mode Équation';
      default:
        return 'Résultat';
    }
  }

  // Obtention du message de record
  String _getRecordMessage() {
    if (widget.initialRecord == 0) {
      return "🎮 Première Partie !\nVotre score de référence est maintenant ${widget.score} points.";
    } else if (widget.score > widget.initialRecord) {
      int improvement = widget.score - widget.initialRecord;
      return "🎉 NOUVEAU RECORD ! +$improvement points\nAncien record: ${widget.initialRecord}";
    } else if (widget.score == widget.initialRecord) {
      return "Égalité avec votre record !\nContinuez comme ça !";
    } else {
      return "Record à battre: ${widget.initialRecord}\nContinuez vos efforts !";
    }
  }

  // Vérification si le niveau est complètement validé
  bool _isLevelComplete() {
    final progression = widget.profile.progression[widget.level];
    if (progression == null) return false;
    return progression.values.every((value) => value['validation'] == 1);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF564560),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              // Division de l'écran en trois sections (30%, 60%, 10%)
              final headerHeight = screenHeight * 0.3;
              final listHeight = screenHeight * 0.6;
              final footerHeight = screenHeight * 0.1;

              return Column(
                children: [
                  // En-tête avec score et messages (30% de l'écran)
                  SizedBox(
                    height: headerHeight,
                    child: _buildScoreSection(screenWidth, headerHeight),
                  ),
                  // Liste des opérations (60% de l'écran)
                  SizedBox(
                    height: listHeight,
                    child: _buildOperationsList(screenWidth, listHeight),
                  ),
                  // Boutons d'action (10% de l'écran)
                  SizedBox(
                    height: footerHeight,
                    child: _buildActionButtons(screenWidth, footerHeight),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }Widget _buildScoreSection(double screenWidth, double sectionHeight) {
    return Stack(
      children: [
        Container(
          width: screenWidth,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            children: [
              // Titre principal - 20% de la hauteur de section
              SizedBox(
                height: sectionHeight * 0.15,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    widget.isProgressionMode ? widget.operationType : _getModeTitle(),
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Contenu principal - 80% de la hauteur de section
              SizedBox(
                height: sectionHeight * 0.85,
                child: widget.isProgressionMode
                    ? _buildProgressionContent(screenWidth, sectionHeight * 0.8)
                    : _buildScoreContent(screenWidth, sectionHeight * 0.8),
              ),
            ],
          ),
        ),
        if (_showConfetti) _buildConfetti(),
      ],
    );
  }



  Widget _buildProgressionContent(double width, double height) {
    // Définir les proportions pour chaque élément
    double titleHeight = height * 0.2; // 20% de la hauteur pour le titre (niveau)
    double subtitleHeight = height * 0.15; // 20% pour le sous-titre (opérateur validé)
    double messageHeight = height * 0.35; // 60% pour le message de félicitations

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Titre "Niveau X"
          SizedBox(
            height: titleHeight,
            child: Center(
              child: Text(
                'Niveau ${widget.level}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontWeight: FontWeight.bold,
                  fontSize: titleHeight * 0.5, // Taille adaptée à la hauteur allouée
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Sous-titre "Validation"
          SizedBox(
            height: subtitleHeight,
            child: Center(
              child: Text(
                _getProgressionTitle(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontWeight: FontWeight.bold,
                  fontSize: subtitleHeight * 0.5, // Taille adaptée à la hauteur allouée
                  color: Colors.yellow,
                ),
              ),
            ),
          ),
          // Message de félicitations
          SizedBox(
            height: messageHeight,
            child: Center(
              child: Text(
                _getProgressionMessage(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontSize: messageHeight * 0.2, // Taille adaptée à la hauteur allouée
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildScoreContent(double width, double height) {
    double titleHeight = height * 0.2; // 20% pour le titre
    double scoreHeight = height * 0.4; // 40% pour le score
    double messageHeight = height * 0.3; // 40% pour le message

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Titre "Score Final"
          SizedBox(
            height: titleHeight,
            child: Center(
              child: Text(
                'Score Final',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontWeight: FontWeight.bold,
                  fontSize: titleHeight * 0.5, // Taille basée sur la hauteur allouée
                  color: Colors.yellow,
                ),
              ),
            ),
          ),
          // Score
          SizedBox(
            height: scoreHeight,
            child: Center(
              child: Text(
                '${widget.score}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontWeight: FontWeight.bold,
                  fontSize: scoreHeight * 0.5, // Taille basée sur la hauteur allouée
                  color: Colors.yellow,
                ),
              ),
            ),
          ),
          // Message record
          SizedBox(
            height: messageHeight,
            child: Center(
              child: Text(
                _getRecordMessage(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontSize: messageHeight * 0.2, // Taille basée sur la hauteur allouée
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildOperationsList(double width, double height) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.03, // Marge horizontale de 3%
        vertical: height * 0.0, // Marge verticale de 2%
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _currentOperationIndex,
        builder: (context, currentIndex, child) {
          return ListView.builder(
            controller: _scrollController,
            itemCount: currentIndex + 1,
            padding: EdgeInsets.all(width * 0.02), // Padding interne de 2%
            itemBuilder: (context, index) => _buildOperationItem(
              widget.operationsHistory[index],
              width,
              height * 0.1, // Hauteur de chaque item 15% de la hauteur disponible
            ),
          );
        },
      ),
    );
  }


  Widget _buildOperationItem(Map<String, dynamic> operation, double width, double height) {
    final bool isCorrect = operation['isCorrect'];

    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: height * 0.1), // Espace entre chaque item
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Question - 60% de la largeur
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.only(left: width * 0.02),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  operation['question'],
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Réponse - 25% de la largeur
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.02),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green : Colors.red,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  operation['answer'].toString(),
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Icône - 15% de la largeur
          Expanded(
            flex: 2,
            child: Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double width, double height) {
    bool showRetryButton = (!widget.isCompetition) && // Hors compétition
        (!widget.hasValidatedOperator || !widget.isProgressionMode); // Conditions pour rapidité/problème/équation ou progression

    return Container(
      padding: EdgeInsets.all(width * 0.02),
      child: Row(
        children: [
          // Bouton Retour
          Expanded(
            child: _buildButton(
              'Retour',
                  () => _handleReturn(),
              Colors.yellow,
              height,
            ),
          ),
          // Bouton Réessayer
          if (showRetryButton) ...[
            SizedBox(width: width * 0.02),
            Expanded(
              child: _buildButton(
                'Réessayer',
                    () => _handleRetry(),
                Colors.green,
                height,
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildButton(String text, VoidCallback onPressed, Color color, double height) {
    return SizedBox(
      height: height * 0.8, // 80% de la hauteur disponible
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'PixelFont',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Méthodes utilitaires pour les titres et messages
  String _getProgressionTitle() {
    if (widget.hasValidatedOperator) {
      return _isLevelComplete()
          ? '🎉 NIVEAU ${widget.level} TERMINÉ! 🎉'
          : '🌟 Opérateur ${widget.operationType} validé! 🌟';
    }
    return 'Continuez vos efforts !';
  }

  String _getProgressionMessage() {
    if (widget.hasValidatedOperator) {
      return _isLevelComplete()
          ? 'Félicitations!\nVous avez validé tous les opérateurs'
          : 'Excellent!\nContinuez avec les autres opérateurs';
    }
    return 'Il vous manque ${widget.totalQuestionsNeeded - widget.score}\nbonnes réponses';
  }

  Widget _buildConfetti() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi / 2,
        maxBlastForce: 5,
        minBlastForce: 3,
        emissionFrequency: 0.1,
        numberOfParticles: 30,
        gravity: 0.1,
        shouldLoop: false,
        colors: const [
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple
        ],
      ),
    );
  }

  // Gestion de la navigation
  void _handleReturn() {
    if (widget.isCompetition) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompetitionScreen(
            profile: widget.profile,
            competitionId: widget.competitionId!,
          ),
        ),
      );
    } else if (widget.isProgressionMode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProgressionModeScreen(
            profile: widget.profile,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ModeSelectionScreen(
            profile: widget.profile,
          ),
        ),
      );
    }
  }

  void _handleRetry() {
    if (widget.isProgressionMode) {
      // Mode Progression
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProgressionScreen(
            mode: widget.operationType,
            level: widget.level,
            duration: 60,
            profile: widget.profile,
            isInitialTest: false,
            isCompetition: false,
          ),
        ),
      );
    } else if (widget.gameMode == 'rapid') {
      // Mode Rapidité
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RapidityModeScreen(
            profile: widget.profile,
            isCompetition: false, // Assurez-vous que la compétition est désactivée
          ),
        ),
      );
    } else if (widget.gameMode == 'problem') {
      // Mode Problème
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProblemModeScreen(
            profile: widget.profile,
            isCompetition: false,
          ),
        ),
      );
    } else if (widget.gameMode == 'equation') {
      // Mode Équation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EquationsModeScreen(
            profile: widget.profile,
            isCompetition: false,
          ),
        ),
      );
    } else {
      // Gestion par défaut (si un autre mode est ajouté à l'avenir)
      print("Mode non supporté pour le retry : ${widget.gameMode}");
    }
  }


  @override
  void dispose() {
    _confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
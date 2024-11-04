import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:mathosproject/sound_manager.dart';
import 'package:mathosproject/widgets/pacmanbutton.dart';

class EndGameAnalysisScreen extends StatefulWidget {
  final int score;
  final List<Map<String, dynamic>> operationsHistory;
  final int initialRecord;
  final String gameMode;
  final bool isCompetition; // Nouveau paramètre
  final String? competitionId; // Optionnel, pour le retour à la bonne compétition
  final AppUser profile; // Ajout du profile

  EndGameAnalysisScreen({
    required this.score,
    required this.operationsHistory,
    required this.initialRecord,
    required this.gameMode,
    this.isCompetition = false,
    this.competitionId,
    required this.profile, // Nouveau paramètre requis

  });


  @override
  _EndGameAnalysisScreenState createState() => _EndGameAnalysisScreenState();
}

class _EndGameAnalysisScreenState extends State<EndGameAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late Animation<int> _scoreAnimation;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  int _currentOperationIndex = 0;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _playOperationsAnimation();
    _initializeHapticFeedback();
  }

  void _initializeHapticFeedback() {
    if (widget.score > widget.initialRecord) {
      HapticFeedback.heavyImpact();
    }
  }

  void _initializeAnimations() {
    _scoreAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scoreAnimation = IntTween(
      begin: 0,
      end: widget.score,
    ).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _scoreAnimationController.forward().then((_) {
      setState(() => _showButton = true);
    });
  }

  Color get _modeColor {
    switch (widget.gameMode) {
      case 'rapid':
        return Color(0xFF00FFFF);
      case 'problem':
        return Color(0xFF00FF00);
      case 'equation':
        return Color(0xFFEC003E);
      default:
        return Colors.yellow;
    }
  }

  String get _modeTitle {
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

  void _playOperationsAnimation() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (_currentOperationIndex < widget.operationsHistory.length - 1) {
        setState(() {
          _currentOperationIndex++;
        });
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      } else {
        timer.cancel();
      }
    });
  }

  Widget _buildScoreSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      color: Color(0xFF564560),
      child: Column(
        children: [
          Text(
            _modeTitle,
            style: TextStyle(
              fontFamily: 'PixelFont',
              fontSize: 20,
              color: Colors.white, // Changé de _modeColor à Colors.white
              shadows: [
                Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Score Final',
            style: TextStyle(
              fontFamily: 'PixelFont',
              fontSize: 24,
              color: Colors.yellow,
              shadows: [
                Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
              ],
            ),
          ),
          SizedBox(height: 8),
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Text(
                '${_scoreAnimation.value}',
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontSize: 48,
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 6),
                  ],
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    _getRecordMessage(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      fontSize: 18,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }



  Widget _buildOperationsList() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.yellow.withOpacity(0.3), // Changé de _modeColor à Colors.yellow
              width: 2
          ),
        ),
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          itemCount: _currentOperationIndex + 1,
          itemBuilder: (context, index) {
            final operation = widget.operationsHistory[index];
            final isCorrect = operation['isCorrect'];

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      operation['question'],
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: widget.gameMode == 'problem' ? 14 : 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      operation['answer'].toString(),
                      style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }



  Widget _buildReturnButton() {
    return AnimatedOpacity(
      opacity: _showButton ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: PacManButton(
          text: 'Retour',
          onPressed: () {
            if (widget.isCompetition) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CompetitionScreen(
                    profile: widget.profile, // Maintenant on a accès au profile
                    competitionId: widget.competitionId!,
                  ),
                ),
              );
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ),
    );
  }



  String _getRecordMessage() {
    if (widget.initialRecord == 0) {
      return "🎮 Première Partie !\nVotre score de référence est maintenant ${widget.score} points.";
    } else if (widget.score > widget.initialRecord) {
      int improvement = widget.score - widget.initialRecord;
      return "🎉 NOUVEAU RECORD ! +$improvement points\nAncien record: ${widget.initialRecord}";
    } else if (widget.score == widget.initialRecord) {
      return "Égalité avec votre record !\nContinuez comme ça !";
    } else {
      return "Record à battre: ${widget.initialRecord}\nVous y êtes presque !";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF564560),
        child: SafeArea(
          child: Column(
            children: [
              _buildScoreSection(),
              _buildOperationsList(),
              _buildReturnButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
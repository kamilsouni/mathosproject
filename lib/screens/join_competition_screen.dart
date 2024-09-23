import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:mathosproject/widgets/PacManButton.dart';

class JoinCompetitionScreen extends StatefulWidget {
  final AppUser profile;

  JoinCompetitionScreen({required this.profile});

  @override
  _JoinCompetitionScreenState createState() => _JoinCompetitionScreenState();
}

class _JoinCompetitionScreenState extends State<JoinCompetitionScreen> {
  final TextEditingController _competitionIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _competitionIdController.dispose();
    super.dispose();
  }

  Future<void> _joinCompetition() async {
    setState(() {
      _isLoading = true;
    });

    final competitionId = _competitionIdController.text.trim();
    if (competitionId.isNotEmpty) {
      try {
        bool isConnected = await ConnectivityManager().isConnected();

        if (isConnected) {
          DocumentSnapshot competitionSnapshot = await FirebaseFirestore.instance
              .collection('competitions')
              .doc(competitionId)
              .get();

          if (competitionSnapshot.exists) {
            await FirebaseFirestore.instance
                .collection('competitions')
                .doc(competitionId)
                .collection('participants')
                .doc(widget.profile.id)
                .set({
              'name': widget.profile.name,
              'rapidTests': 0,
              'ProblemTests': 0,
              'totalPoints': 0,
              'flagUrl': widget.profile.flag,
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CompetitionScreen(
                  profile: widget.profile,
                  competitionId: competitionId,
                ),
              ),
            );
          } else {
            _showErrorSnackBar('Compétition non trouvée');
          }
        } else {
          await UserPreferences.saveProfileLocally(widget.profile);
          _showErrorSnackBar('Hors ligne. Les données seront synchronisées une fois la connexion rétablie.');
        }
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la jointure : $e');
      }
    } else {
      _showErrorSnackBar('Veuillez entrer un ID de compétition');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(title: 'Rejoindre une compétition', showBackButton: true),
      body: Container(
        color: Color(0xFF564560), // Fond violet comme la page d'accueil
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.yellow, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _competitionIdController,
                  style: TextStyle(color: Colors.white, fontFamily: 'PixelFont'),
                  decoration: InputDecoration(
                    labelText: 'ID de la compétition',
                    labelStyle: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              PacManButton(
                text: 'Rejoindre la compétition',
                onPressed: _joinCompetition,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
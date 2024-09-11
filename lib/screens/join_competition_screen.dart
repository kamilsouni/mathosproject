import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/user_preferences.dart';

class JoinCompetitionScreen extends StatefulWidget {
  final AppUser profile;

  JoinCompetitionScreen({required this.profile});

  @override
  _JoinCompetitionScreenState createState() => _JoinCompetitionScreenState();
}

class _JoinCompetitionScreenState extends State<JoinCompetitionScreen> {
  final TextEditingController _competitionIdController = TextEditingController();

  @override
  void dispose() {
    _competitionIdController.dispose();
    super.dispose();
  }

  Future<void> _joinCompetition() async {
    final competitionId = _competitionIdController.text.trim();
    if (competitionId.isNotEmpty) {
      try {
        // Vérifier la connectivité
        bool isConnected = await ConnectivityManager().isConnected();

        if (isConnected) {
          // Check if the competition exists
          DocumentSnapshot competitionSnapshot = await FirebaseFirestore.instance
              .collection('competitions')
              .doc(competitionId)
              .get();

          if (competitionSnapshot.exists) {
            // Add the user as a participant in Firestore
            await FirebaseFirestore.instance
                .collection('competitions')
                .doc(competitionId)
                .collection('participants')
                .doc(widget.profile.id)
                .set({
              'name': widget.profile.name,
              'rapidTests': 0,
              'precisionTests': 0,
              'totalPoints': 0,
              'flagUrl': widget.profile.flag, // Ensure the flag URL is set
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Compétition non trouvée')),
            );
          }
        } else {
          // Sauvegarder localement si hors ligne
          await UserPreferences.saveProfileLocally(widget.profile);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hors ligne. Les données seront synchronisées une fois la connexion rétablie.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la jointure : $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un ID de compétition')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rejoindre une compétition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _competitionIdController,
              decoration: InputDecoration(
                labelText: 'ID de la compétition',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _joinCompetition,
              child: Text('Rejoindre la compétition'),
            ),
          ],
        ),
      ),
    );
  }
}

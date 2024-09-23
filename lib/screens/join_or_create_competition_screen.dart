import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/create_competition_screen.dart';
import 'package:mathosproject/screens/join_competition_screen.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';

class JoinOrCreateCompetitionScreen extends StatefulWidget {
  final AppUser profile;

  JoinOrCreateCompetitionScreen({required this.profile});

  @override
  _JoinOrCreateCompetitionScreenState createState() =>
      _JoinOrCreateCompetitionScreenState();
}

class _JoinOrCreateCompetitionScreenState
    extends State<JoinOrCreateCompetitionScreen> {
  List<Map<String, dynamic>> _competitions = [];

  @override
  void initState() {
    super.initState();
    _fetchCompetitions();
  }

  Future<void> _fetchCompetitions() async {
    final userId = widget.profile.id;

    bool isConnected = await ConnectivityManager().isConnected();

    if (isConnected) {
      final competitionsSnapshot =
      await FirebaseFirestore.instance.collection('competitions').get();

      final competitions = await Future.wait(
          competitionsSnapshot.docs.map((doc) async {
            final participantSnapshot =
            await doc.reference.collection('participants').doc(userId).get();
            if (participantSnapshot.exists) {
              return {
                'id': doc.id,
                'name': doc['name'],
              };
            }
            return null;
          }).toList());

      setState(() {
        _competitions = competitions.whereType<Map<String, dynamic>>().toList();
      });

      // Enregistrer les compétitions localement
      await HiveDataManager.saveData(
          'competitions', 'user_$userId', _competitions);
    } else {
      // Charger les compétitions depuis le stockage local
      List<Map<String, dynamic>>? localCompetitions = await HiveDataManager
          .getData<List<Map<String, dynamic>>>('competitions', 'user_$userId');

      setState(() {
        _competitions = localCompetitions ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(title: 'Mode Compétition', showBackButton: true),
      body: Container(
        color: Color(0xFF564560), // Fond violet
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 2),
                      Text(
                        'Créez ou rejoignez une compétition',
                        style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompetitionButton(
                        title: 'Créer',
                        icon: Icons.add,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateCompetitionScreen(
                                  profile: widget.profile),
                            ),
                          );
                        },
                      ),
                      _buildCompetitionButton(
                        title: 'Rejoindre',
                        icon: Icons.group_add,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JoinCompetitionScreen(
                                  profile: widget.profile),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20), // Ajout d'un espace de 20 pixels
                Expanded(
                  flex: 6,
                  child: _buildJoinedCompetitionsList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompetitionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.black, width: 2),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.black),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'PixelFont',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinedCompetitionsList() {
    if (_competitions.isEmpty) {
      return Center(
        child: Text(
          'Aucune compétition rejointe',
          style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        Text(
          'Vos compétitions',
          style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont', fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _competitions.length,
            itemBuilder: (context, index) {
              final competition = _competitions[index];
              return Card(
                color: Colors.white.withOpacity(0.1),
                margin: EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.yellow, width: 2),
                ),
                child: ListTile(
                  title: Text(
                    competition['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PixelFont',
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.yellow),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompetitionScreen(
                          profile: widget.profile,
                          competitionId: competition['id'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

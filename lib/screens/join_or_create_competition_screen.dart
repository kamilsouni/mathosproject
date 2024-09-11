import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/create_competition_screen.dart';
import 'package:mathosproject/screens/join_competition_screen.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';

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
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Rejoindre ou créer une compétition',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: SvgPicture.asset(
                'assets/fond_d_ecran.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: screenHeight * 0.1,
              ),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    children: [
                      _buildCompetitionButton(
                        title: 'Créer une compétition',
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
                        title: 'Rejoindre une nouvelle compétition',
                        icon: Icons.group,
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
                  SizedBox(
                      height: 16), // Ajustement de la hauteur pour rapprocher la liste
                  _buildJoinedCompetitionsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: title,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJoinedCompetitionsList() {
    if (_competitions.isEmpty) {
      return Center(child: Text('Aucune compétition rejointe.'));
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _competitions.length,
        itemBuilder: (context, index) {
          final competition = _competitions[index];
          return Card(
            elevation: 4,
            margin:
            EdgeInsets.symmetric(vertical: 4), // Ajustement de la marge verticale
            child: ListTile(
              title: Text(
                competition['name'],
                style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
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
    );
  }
}

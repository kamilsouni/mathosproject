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
    extends State<JoinOrCreateCompetitionScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _competitions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchCompetitions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCompetitions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchCompetitions();
    }
  }

  Future<void> _fetchCompetitions() async {
    setState(() {
      _isLoading = true;
    });

    final userId = widget.profile.id;

    try {
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
                  'name': doc.data()['name'],
                };
              }
              return null;
            }).toList());

        setState(() {
          _competitions = competitions.whereType<Map<String, dynamic>>().toList();
          _isLoading = false;
        });

        await HiveDataManager.saveData(
            'competitions', 'user_$userId', _competitions);
      } else {
        final localCompetitions = await HiveDataManager.getData<List<dynamic>>(
            'competitions', 'user_$userId');

        setState(() {
          _competitions = localCompetitions?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des compétitions: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
          style: TextStyle(
              color: Colors.yellow,
              fontFamily: 'PixelFont',
              fontSize: 20,
              fontWeight: FontWeight.bold),
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
                    ).then((_) => _fetchCompetitions()); // Rafraîchir après retour
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(title: 'Mode Compétition', showBackButton: true),
      body: RefreshIndicator(
        onRefresh: _fetchCompetitions,
        child: Container(
          color: Color(0xFF564560),
          child: SafeArea(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.yellow))
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            ).then((_) => _fetchCompetitions());
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
                            ).then((_) => _fetchCompetitions());
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    flex: 6,
                    child: _buildJoinedCompetitionsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
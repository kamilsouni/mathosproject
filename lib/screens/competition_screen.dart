import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';
import 'package:mathosproject/screens/problem_mode_screen.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:country_flags/country_flags.dart';

class CompetitionScreen extends StatefulWidget {
  final AppUser profile;
  final String competitionId;

  CompetitionScreen({required this.profile, required this.competitionId});

  @override
  _CompetitionScreenState createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  late Map<String, dynamic> _competitionData = {};
  late List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  int totalRapidTests = 0;
  int totalProblemTests = 0;
  int totalEquationTests = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    ConnectivityManager().monitorConnectivityChanges((isConnected) {
      if (isConnected) {
        _syncDataWithFirebase();
      }
    });
  }


  Future<void> _syncDataWithFirebase() async {
    var localCompetitionData = await HiveDataManager.getData('competitions', widget.competitionId) ?? {};
    var localParticipantsData = await HiveDataManager.getAllData('competitionParticipants_${widget.competitionId}');

    // Mettre à jour les données de la compétition
    await FirebaseFirestore.instance
        .collection('competitions')
        .doc(widget.competitionId)
        .set(localCompetitionData, SetOptions(merge: true));

    // Mettre à jour les données des participants
    for (var entry in localParticipantsData.entries) {
      await FirebaseFirestore.instance
          .collection('competitions')
          .doc(widget.competitionId)
          .collection('participants')
          .doc(entry.key)
          .set(entry.value, SetOptions(merge: true));
    }

    // Recharger les données après la synchronisation
    await _loadData();
  }


  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    if (await ConnectivityManager().isConnected()) {
      await _loadDataFromFirebase();
    } else {
      await _loadDataFromLocal();
    }

    setState(() => _isLoading = false);
  }



  Future<void> _loadDataFromFirebase() async {
    try {
      var competitionDoc = await FirebaseFirestore.instance
          .collection('competitions')
          .doc(widget.competitionId)
          .get();

      _competitionData = competitionDoc.data() ?? {};

      var participantsSnapshot = await FirebaseFirestore.instance
          .collection('competitions')
          .doc(widget.competitionId)
          .collection('participants')
          .get();

      _participants = participantsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Sauvegarde locale des données
      await HiveDataManager.saveData('competitions', widget.competitionId, _competitionData);
      for (var participant in _participants) {
        await HiveDataManager.saveData('competitionParticipants_${widget.competitionId}', participant['id'], participant);
      }
    } catch (e) {
      print('Erreur lors du chargement des données depuis Firebase: $e');
    }
    _updateTotalTests();
  }

  Future<void> _loadDataFromLocal() async {
    _competitionData = await HiveDataManager.getData('competitions', widget.competitionId) ?? {};
    var localParticipantsData = await HiveDataManager.getAllData('competitionParticipants_${widget.competitionId}');
    _participants = localParticipantsData.entries.map((e) => {'id': e.key, ...Map<String, dynamic>.from(e.value)}).toList();
    _updateTotalTests();
  }

  void _updateTotalTests() {
    totalRapidTests = _competitionData['numRapidTests'] ?? 0;
    totalProblemTests = _competitionData['numProblemTests'] ?? 0;
  }

  Future<void> _startTest(String type) async {
    var currentParticipant = _participants.firstWhere((p) => p['id'] == widget.profile.id, orElse: () => {});
    int completedTests = currentParticipant['${type.toLowerCase()}Tests'] ?? 0;
    int totalTests = type == 'Rapidité' ? totalRapidTests : totalProblemTests;

    if (completedTests >= totalTests) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tous les tests de $type ont été réalisés pour cette compétition.')),
      );
      return;
    }


    bool? dataChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => type == 'Rapidité'
            ? RapidityModeScreen(profile: widget.profile, isCompetition: true, competitionId: widget.competitionId)
            : ProblemModeScreen(profile: widget.profile, isCompetition: true, competitionId: widget.competitionId),
      ),
    );

    if (dataChanged == true) {
      await _loadData();
    }
  }
  void _shareCompetition() {
    final competitionCode = widget.competitionId;
    final competitionMessage = 'Rejoignez ma compétition sur Mathos !\n\n'
        'Allez dans Mode Challenge > Rejoindre une nouvelle compétition\n'
        'et entrez le code suivant :\n'
        '```\n'
        '$competitionCode\n'
        '```\n'
        'Copiez le code ci-dessus et collez-le dans l\'application.';

    Share.share(competitionMessage);
  }

  void _copyCompetitionId() {
    Clipboard.setData(ClipboardData(text: widget.competitionId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ID de la compétition copié dans le presse-papiers')),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Partager le lien'),
                onTap: () {
                  Navigator.pop(context);
                  _shareCompetition();
                },
              ),
              ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copier le code'),
                onTap: () {
                  Navigator.pop(context);
                  _copyCompetitionId();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    ConnectivityManager().dispose();
    super.dispose();
  }


  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required int completedTests,
    required int totalTests,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: completedTests < totalTests ? Colors.black.withOpacity(0.7) : Colors.grey,
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            '$completedTests/$totalTests',
            style: TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: TopAppBar(title: 'Chargement...', showBackButton: true),
        body: Center(child: CircularProgressIndicator(color: Colors.yellow)),
      );
    }

    var currentParticipant = _participants.firstWhere((p) => p['id'] == widget.profile.id, orElse: () => {});
    int completedRapidTests = currentParticipant['rapidTests'] ?? 0;
    int completedProblemTests = currentParticipant['ProblemTests'] ?? 0;
    int completedEquationTests = currentParticipant['equationTests'] ?? 0;

    return Scaffold(
      appBar: TopAppBar(
        title: _competitionData['name'] ?? 'Compétition',
        showBackButton: true,
      ),
      body: Container(
        color: Color(0xFF564560), // Fond uni violet
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _showShareOptions,
                icon: Icon(Icons.share, color: Colors.black),
                label: Text('Partager', style: TextStyle(color: Colors.black, fontFamily: 'PixelFont')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTestButton('Rapidité', Icons.flash_on, () => _startTest('Rapidité'), completedRapidTests, totalRapidTests),
                  _buildTestButton('Probleme', Icons.precision_manufacturing, () => _startTest('Précision'), completedProblemTests, totalProblemTests),
                  _buildTestButton('Equation', Icons.functions, () => _startTest('Équations'), completedEquationTests, totalEquationTests),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _buildParticipantsTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, IconData icon, VoidCallback onPressed, int completedTests, int totalTests) {
    bool isEnabled = completedTests < totalTests;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? Colors.yellow : Colors.yellow.withOpacity(0.3),
            padding: EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.white, width: 2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isEnabled ? Colors.black : Colors.black.withOpacity(0.5)),
              SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                      color: isEnabled ? Colors.black : Colors.black.withOpacity(0.5),
                      fontFamily: 'PixelFont',
                      fontSize: 12
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$completedTests/$totalTests',
                  style: TextStyle(
                      color: isEnabled ? Colors.black : Colors.black.withOpacity(0.5),
                      fontFamily: 'PixelFont',
                      fontSize: 12
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsTable() {
    _participants.sort((a, b) => (b['totalPoints'] ?? 0).compareTo(a['totalPoints'] ?? 0));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.yellow, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'CLASSEMENT',
              style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont', fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                var participant = _participants[index];
                return Container(
                  height: 40, // Hauteur fixe pour chaque ligne
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.yellow.withOpacity(0.3), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(color: Colors.black, fontFamily: 'PixelFont', fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      CountryFlag.fromCountryCode(
                        participant['flag'] ?? 'XX',
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          participant['name'] ?? 'Inconnu',
                          style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${participant['totalPoints'] ?? 0}',
                          style: TextStyle(color: Colors.black, fontFamily: 'PixelFont', fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/dialog_manager.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/problem_mode_screen.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';
import 'package:mathosproject/screens/equations_mode_screen.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
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

class _CompetitionScreenState extends State<CompetitionScreen> with WidgetsBindingObserver {
  late Map<String, dynamic> _competitionData = {};
  late List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  int totalRapidTests = 0;
  int totalProblemTests = 0;
  int totalEquationTests = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
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

    if (await ConnectivityManager().isConnected()) {
      try {
        await FirebaseFirestore.instance
            .collection('competitions')
            .doc(widget.competitionId)
            .set(localCompetitionData, SetOptions(merge: true));

        for (var entry in localParticipantsData.entries) {
          await FirebaseFirestore.instance
              .collection('competitions')
              .doc(widget.competitionId)
              .collection('participants')
              .doc(entry.key)
              .set(entry.value, SetOptions(merge: true));
        }

        await _loadData();
      } catch (e) {
        print('Erreur lors de la synchronisation: $e');
      }
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      if (await ConnectivityManager().isConnected()) {
        await _loadDataFromFirebase();
      } else {
        await _loadDataFromLocal();
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDataFromFirebase() async {
    try {
      var competitionDoc = await FirebaseFirestore.instance
          .collection('competitions')
          .doc(widget.competitionId)
          .get();

      var participantsSnapshot = await FirebaseFirestore.instance
          .collection('competitions')
          .doc(widget.competitionId)
          .collection('participants')
          .get();

      if (mounted) {
        setState(() {
          _competitionData = competitionDoc.data() ?? {};
          _participants = participantsSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList();
          _updateTotalTests();
        });
      }

      await HiveDataManager.saveData('competitions', widget.competitionId, _competitionData);
      for (var participant in _participants) {
        await HiveDataManager.saveData(
            'competitionParticipants_${widget.competitionId}',
            participant['id'],
            participant);
      }
    } catch (e) {
      print('Erreur lors du chargement depuis Firebase: $e');
    }
  }

  Future<void> _loadDataFromLocal() async {
    try {
      var localData = await HiveDataManager.getData('competitions', widget.competitionId);
      var localParticipants = await HiveDataManager.getAllData('competitionParticipants_${widget.competitionId}');

      if (mounted) {
        setState(() {
          _competitionData = localData ?? {};
          _participants = localParticipants.entries
              .map((e) => {'id': e.key, ...Map<String, dynamic>.from(e.value)})
              .toList();
          _updateTotalTests();
        });
      }
    } catch (e) {
      print('Erreur lors du chargement local: $e');
    }
  }

  void _updateTotalTests() {
    totalRapidTests = _competitionData['numRapidTests'] ?? 0;
    totalProblemTests = _competitionData['numProblemTests'] ?? 0;
    totalEquationTests = _competitionData['numEquationTests'] ?? 0;
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

  Future<void> _startTest(String type) async {
    var currentParticipant = _participants.firstWhere(
          (p) => p['id'] == widget.profile.id,
      orElse: () => {},
    );

    int completedTests;
    int totalTests;

    switch (type) {
      case 'Rapidité':
        completedTests = currentParticipant['rapidTests'] ?? 0;
        totalTests = totalRapidTests;
        break;
      case 'Probleme':
        completedTests = currentParticipant['ProblemTests'] ?? 0;
        totalTests = totalProblemTests;
        break;
      case 'Equation':
        completedTests = currentParticipant['equationTests'] ?? 0;
        totalTests = totalEquationTests;
        break;
      default:
        return;
    }

    if (completedTests >= totalTests) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tous les tests de $type ont été réalisés pour cette compétition.')),
      );
      return;
    }

    bool? dataChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (type) {
            case 'Rapidité':
              return RapidityModeScreen(
                profile: widget.profile,
                isCompetition: true,
                competitionId: widget.competitionId,
              );
            case 'Probleme':
              return ProblemModeScreen(
                profile: widget.profile,
                isCompetition: true,
                competitionId: widget.competitionId,
              );
            case 'Equation':
              return EquationsModeScreen(
                profile: widget.profile,
                isCompetition: true,
                competitionId: widget.competitionId,
              );
            default:
              throw Exception('Type de test non reconnu: $type');
          }
        },
      ),
    );

    // Rafraîchir les données après le retour d'une partie
    await _loadData();
  }

  Widget _buildTestButton(String label, IconData icon, VoidCallback onPressed, int completedTests, int totalTests) {
    bool isEnabled = completedTests < totalTests;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: isEnabled ? () async {
            bool shouldStart = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Color(0xFF564560),
                  title: Text(
                    'Commencer le test',
                    style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont'),
                  ),
                  content: Text(
                    'Une fois commencé, ce test sera comptabilisé même si vous l\'abandonnez.',
                    style: TextStyle(color: Colors.white, fontFamily: 'PixelFont'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'Annuler',
                        style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont'),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Commencer',
                        style: TextStyle(color: Colors.green, fontFamily: 'PixelFont'),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              },
            ) ?? false;

            if (shouldStart) {
              onPressed();
            }
          } : null,
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
              Icon(
                icon,
                color: isEnabled ? Colors.black : Colors.black.withOpacity(0.5),
                size: 24,
              ),
              SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? Colors.black : Colors.black.withOpacity(0.5),
                    fontFamily: 'PixelFont',
                    fontSize: 12,
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
                    fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    // Trier les participants par points
    _participants.sort((a, b) => (b['totalPoints'] ?? 0).compareTo(a['totalPoints'] ?? 0));

    return Scaffold(
      appBar: TopAppBar(
        title: _competitionData['name'] ?? 'Compétition',
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.yellow,
        child: Container(
          height: double.infinity,  // Ajoute cette ligne pour que le conteneur s'étende sur toute la hauteur
          color: Color(0xFF564560),  // Violet
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.yellow))
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _shareCompetition,
                    icon: Icon(Icons.share, color: Colors.black),
                    label: Text('Partager',
                        style: TextStyle(color: Colors.black, fontFamily: 'PixelFont')
                    ),
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
                      _buildTestButton(
                        'Rapidité',
                        Icons.flash_on,
                            () => _startTest('Rapidité'),
                        _participants.firstWhere(
                              (p) => p['id'] == widget.profile.id,
                          orElse: () => {'rapidTests': 0},
                        )['rapidTests'] ?? 0,
                        totalRapidTests,
                      ),
                      _buildTestButton(
                        'Probleme',
                        Icons.precision_manufacturing,
                            () => _startTest('Probleme'),
                        _participants.firstWhere(
                              (p) => p['id'] == widget.profile.id,
                          orElse: () => {'ProblemTests': 0},
                        )['ProblemTests'] ?? 0,
                        totalProblemTests,
                      ),
                      _buildTestButton(
                        'Equation',
                        Icons.functions,
                            () => _startTest('Equation'),
                        _participants.firstWhere(
                              (p) => p['id'] == widget.profile.id,
                          orElse: () => {'equationTests': 0},
                        )['equationTests'] ?? 0,
                        totalEquationTests,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'CLASSEMENT',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontFamily: 'PixelFont',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: List.generate(_participants.length, (index) {
                          final participant = _participants[index];
                          return Container(
                            height: 40,
                            margin: EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              border: Border.all(color: Colors.yellow, width: 1),
                              borderRadius: BorderRadius.circular(8),
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
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'PixelFont',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'PixelFont',
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${participant['totalPoints'] ?? 0}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'PixelFont',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

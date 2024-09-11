import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/rapidity_mode_screen.dart';
import 'package:mathosproject/screens/precision_mode_screen.dart';
import 'package:flutter/services.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';

class CompetitionScreen extends StatefulWidget {
  final AppUser profile;
  final String competitionId;

  CompetitionScreen({required this.profile, required this.competitionId});

  @override
  _CompetitionScreenState createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  late Stream<DocumentSnapshot> _competitionStream;
  late Stream<QuerySnapshot> _participantsStream;
  int completedRapidTests = 0;
  int completedPrecisionTests = 0;
  int numRapidTests = 0;
  int numPrecisionTests = 0;
  String competitionName = '';
  Map<String, dynamic> _localParticipantData = {}; // Pour stocker les données locales du participant

  @override
  void initState() {
    super.initState();

    // Initialiser les streams Firebase
    _competitionStream = FirebaseFirestore.instance
        .collection('competitions')
        .doc(widget.competitionId)
        .snapshots();

    _participantsStream = FirebaseFirestore.instance
        .collection('competitions')
        .doc(widget.competitionId)
        .collection('participants')
        .orderBy('totalPoints', descending: true)
        .snapshots();

    // Charger les données initiales
    _loadParticipantData();

    // Configurer la gestion de la connectivité
    ConnectivityManager().monitorConnectivityChanges(
            (isConnected) => _handleConnectivityChange(isConnected),
        widget.competitionId
    );
  }

  Future<void> _loadParticipantData() async {
    bool isConnected = await ConnectivityManager().isConnected();

    if (isConnected) {
      try {
        // Charger les données de la compétition depuis Firebase
        var competitionDoc = await FirebaseFirestore.instance
            .collection('competitions')
            .doc(widget.competitionId)
            .get();

        if (competitionDoc.exists) {
          var data = competitionDoc.data() as Map<String, dynamic>;
          setState(() {
            competitionName = data['name'] ?? 'Compétition';
            numRapidTests = data['numRapidTests'] ?? 0;
            numPrecisionTests = data['numPrecisionTests'] ?? 0;
          });

          // Sauvegarder les données de la compétition localement
          await HiveDataManager.saveData('competitions', widget.competitionId, {
            'name': competitionName,
            'numRapidTests': numRapidTests,
            'numPrecisionTests': numPrecisionTests,
          });
        }

        // Charger les données du participant depuis Firebase
        var participantDoc = await FirebaseFirestore.instance
            .collection('competitions')
            .doc(widget.competitionId)
            .collection('participants')
            .doc(widget.profile.id)
            .get();

        if (participantDoc.exists) {
          var data = participantDoc.data() as Map<String, dynamic>;
          setState(() {
            completedRapidTests = data['rapidTests'] ?? 0;
            completedPrecisionTests = data['precisionTests'] ?? 0;
            _localParticipantData = data;
          });

          // Sauvegarder les données du participant localement
          await HiveDataManager.saveData('competitionParticipants_${widget.competitionId}', widget.profile.id, data);
        }
      } catch (e) {
        print('Erreur lors du chargement des données depuis Firebase: $e');
      }
    } else {
      // Charger les données localement
      await _loadLocalData();
    }

    // Afficher les valeurs pour le débogage
    print('Competition Name: $competitionName');
    print('Rapid Tests: $numRapidTests');
    print('Precision Tests: $numPrecisionTests');
    print('Completed Rapid Tests: $completedRapidTests');
    print('Completed Precision Tests: $completedPrecisionTests');
  }

  Future<void> _loadLocalData() async {
    var competitionData = await HiveDataManager.getData<Map<String, dynamic>>('competitions', widget.competitionId);
    if (competitionData != null) {
      setState(() {
        competitionName = competitionData['name'] ?? 'Compétition';
        numRapidTests = competitionData['numRapidTests'] ?? 0;
        numPrecisionTests = competitionData['numPrecisionTests'] ?? 0;
      });
    }

    var participantData = await HiveDataManager.getData<Map<String, dynamic>>('competitionParticipants_${widget.competitionId}', widget.profile.id);
    if (participantData != null) {
      setState(() {
        completedRapidTests = participantData['rapidTests'] ?? 0;
        completedPrecisionTests = participantData['precisionTests'] ?? 0;
        _localParticipantData = participantData;
      });
    }
  }

  void _handleConnectivityChange(bool isConnected) async {
    if (isConnected) {
      await _syncLocalDataWithFirebase();
      _loadParticipantData(); // Recharger les données après la synchronisation
    }
  }





  Future<void> _syncLocalDataWithFirebase() async {
    try {
      // Récupérer les données locales du participant
      var localParticipantData = await HiveDataManager.getData<Map<String, dynamic>>('competitionParticipants_${widget.competitionId}', widget.profile.id);

      if (localParticipantData != null) {
        // Mettre à jour les données du participant sur Firebase
        await FirebaseFirestore.instance
            .collection('competitions')
            .doc(widget.competitionId)
            .collection('participants')
            .doc(widget.profile.id)
            .set(localParticipantData, SetOptions(merge: true));

        print('Données du participant synchronisées avec Firebase');
      }

      // Récupérer les dernières données de la compétition depuis Firebase
      var competitionDoc = await FirebaseFirestore.instance
          .collection('competitions')
          .doc(widget.competitionId)
          .get();

      if (competitionDoc.exists) {
        var firebaseCompetitionData = competitionDoc.data() as Map<String, dynamic>;

        // Mettre à jour les données locales de la compétition
        await HiveDataManager.saveData('competitions', widget.competitionId, firebaseCompetitionData);

        // Mettre à jour l'état de l'interface utilisateur
        setState(() {
          competitionName = firebaseCompetitionData['name'] ?? 'Compétition';
          numRapidTests = firebaseCompetitionData['numRapidTests'] ?? 0;
          numPrecisionTests = firebaseCompetitionData['numPrecisionTests'] ?? 0;
        });

        print('Données de la compétition mises à jour localement');
      }

      // Récupérer les dernières données du participant depuis Firebase
      var participantDoc = await FirebaseFirestore.instance
          .collection('competitions')
          .doc(widget.competitionId)
          .collection('participants')
          .doc(widget.profile.id)
          .get();

      if (participantDoc.exists) {
        var firebaseParticipantData = participantDoc.data() as Map<String, dynamic>;

        // Mettre à jour les données locales du participant
        await HiveDataManager.saveData('competitionParticipants_${widget.competitionId}', widget.profile.id, firebaseParticipantData);

        // Mettre à jour l'état de l'interface utilisateur
        setState(() {
          completedRapidTests = firebaseParticipantData['rapidTests'] ?? 0;
          completedPrecisionTests = firebaseParticipantData['precisionTests'] ?? 0;
          _localParticipantData = firebaseParticipantData;
        });

        print('Données du participant mises à jour localement');
      }

      // Recharger les données des participants pour mettre à jour le tableau de classement
      await _loadParticipantData();

    } catch (e) {
      print('Erreur lors de la synchronisation des données avec Firebase: $e');
    }
  }










  Future<Map<String, dynamic>> _getUserProfile(String? userId) async {
    print('Fetching profile for user ID: $userId');
    if (userId != null) {
      try {
        var userDoc = await FirebaseFirestore.instance.collection('profiles').doc(userId).get();
        print('Firestore query completed');
        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          print('User document data: $data');
          return data;
        } else {
          print('No document found for user ID: $userId');
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    } else {
      print('User ID is null');
    }
    return {};
  }

  void _startTest(String type) async {
    if ((type == 'Rapidité' && completedRapidTests >= numRapidTests) ||
        (type == 'Précision' && completedPrecisionTests >= numPrecisionTests)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tous les tests de $type ont été réalisés pour cette compétition.')),
      );
      return;
    }

    bool dataChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (type == 'Rapidité') {
            return RapidityModeScreen(
              profile: widget.profile,
              isCompetition: true,
              competitionId: widget.competitionId,
            );
          } else if (type == 'Précision') {
            return PrecisionModeScreen(
              profile: widget.profile,
              isCompetition: true,
              competitionId: widget.competitionId,
            );
          } else {
            return Container();
          }
        },
      ),
    );

    if (dataChanged == true) {
      if (await ConnectivityManager().isConnected()) {
        await _syncLocalDataWithFirebase();
      } else {
        await _loadParticipantData();
      }
      setState(() {}); // Forcer la mise à jour de l'interface utilisateur
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

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? backgroundColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.black.withOpacity(0.7),
        padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double margin = 16.0;

    return Scaffold(
      appBar: CustomAppBar(
        title: competitionName,
        showBackButton: true,
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildButton(
                  label: 'Partager la compétition',
                  icon: Icons.share,
                  onPressed: _showShareOptions,
                ),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: _competitionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var competitionData = snapshot.data!.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildButton(
                                  label: 'Rapidité\n$completedRapidTests/$numRapidTests',
                                  icon: Icons.flash_on,
                                  onPressed: completedRapidTests < numRapidTests
                                      ? () => _startTest('Rapidité')
                                      : null,
                                  backgroundColor: completedRapidTests < numRapidTests
                                      ? Colors.black.withOpacity(0.7)
                                      : Colors.grey,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _buildButton(
                                  label: 'Précision\n$completedPrecisionTests/$numPrecisionTests',
                                  icon: Icons.precision_manufacturing,
                                  onPressed: completedPrecisionTests < numPrecisionTests
                                      ? () => _startTest('Précision')
                                      : null,
                                  backgroundColor: completedPrecisionTests < numPrecisionTests
                                      ? Colors.black.withOpacity(0.7)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              SizedBox(height: 20),
              Text(
                'Classement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getParticipantsData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Aucun participant'));
                      }

                      var participants = snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: Table(
                            border: TableBorder.all(),
                            defaultColumnWidth: IntrinsicColumnWidth(),
                            columnWidths: const <int, TableColumnWidth>{
                              0: IntrinsicColumnWidth(),
                              1: IntrinsicColumnWidth(),
                              2: IntrinsicColumnWidth(),
                              3: IntrinsicColumnWidth(),
                              4: IntrinsicColumnWidth(),
                            },
                            children: [
                              TableRow(
                                children: ['Drapeau', 'Nom', 'Rapidité', 'Précision', 'Points']
                                    .map((header) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  color: Colors.grey[300],
                                  child: Text(
                                    header,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ))
                                    .toList(),
                              ),
                              ...participants.map((participant) => TableRow(
                                children: [
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: _getUserProfile(participant['id']),
                                    builder: (context, profileSnapshot) {
                                      if (profileSnapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                                      } else if (profileSnapshot.hasError) {
                                        return Center(child: Icon(Icons.error, size: 20));
                                      } else {
                                        var profileData = profileSnapshot.data;
                                        return Container(
                                          padding: EdgeInsets.all(4.0),
                                          child: Image.asset(
                                            profileData?['flag'] ?? 'assets/default_flag.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Text(
                                      participant['name'] ?? '',
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Text(
                                      '${participant['rapidTests'] ?? 0}/$numRapidTests',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Text(
                                      '${participant['precisionTests'] ?? 0}/$numPrecisionTests',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Text(
                                      participant['totalPoints'].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              )).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveCompetitionDataLocally() async {
    if (widget.competitionId != null) {
      var competitionData = {
        'name': competitionName,
        'numRapidTests': numRapidTests,
        'numPrecisionTests': numPrecisionTests,
      };
      await HiveDataManager.saveData('competitions', widget.competitionId, competitionData);
    }
  }
  Future<List<Map<String, dynamic>>> _getParticipantsData() async {
    var localParticipantsData = await HiveDataManager.getAllData('competitionParticipants_${widget.competitionId}');

    List<Map<String, dynamic>> participants = localParticipantsData.entries.map((entry) {
      var data = Map<String, dynamic>.from(entry.value);
      data['id'] = entry.key;
      return data;
    }).toList();

    // Trier les participants par points
    participants.sort((a, b) => (b['totalPoints'] ?? 0).compareTo(a['totalPoints'] ?? 0));

    return participants;
  }}
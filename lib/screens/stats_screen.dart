import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/profile_detail_screen.dart';
import 'package:mathosproject/screens/settings_screen.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';

class StatsScreen extends StatefulWidget {
  final AppUser profile;

  StatsScreen({required this.profile});

  @override
  _StatsScreenState createState() => _StatsScreenState();

  String getLevelDescription(int level) {
    switch (level) {
      case 0:
        return "Débutant : Vous n'avez pas encore validé le niveau 1.";
      case 1:
        return "Novice des Nombres : Félicitations, vous avez conquis les bases de l'arithmétique.";
      case 2:
        return "Apprenti Calculateur : Vous avez appris à additionner et soustraire des petites quantités.";
      case 3:
        return "Maître des Multiplications : Bravo, vous connaissez vos tables de multiplication !";
      case 4:
        return "Génie des Calculs : Vous êtes un véritable génie des calculs.";
      case 5:
        return "Calculateur de Compétition : Vous êtes prêt pour les olympiades de mathématiques !";
      case 6:
        return "Maître des Nombres : Vous dominez les mathématiques.";
      case 7:
        return "Calculateur Suprême : Vous êtes un prodige du calcul mental.";
      case 8:
        return "Virtuose des Chiffres : Les calculs complexes ne vous effraient plus.";
      case 9:
        return "Seigneur des Calculs : Vous avez atteint un niveau impressionnant.";
      case 10:
        return "Grand Maître des Mathématiques : Vous êtes le grand maître des mathématiques.";
      default:
        return "";
    }
  }
}

class _StatsScreenState extends State<StatsScreen> {
  late AppUser _profile;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    refreshProfile();
  }

  void refreshProfile() async {
    if (await ConnectivityManager().isConnected()) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_profile.id)
          .get();
      setState(() {
        _profile = AppUser.fromJson(snapshot.data() as Map<String, dynamic>);
      });
    } else {
      AppUser? localProfile = await UserPreferences.getProfileLocally(_profile.id);
      if (localProfile != null) {
        setState(() {
          _profile = localProfile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: TopAppBar(title: 'Statistiques',showBackButton: true),
        body: Container(
          color: Color(0xFF564560),
          child: Column(
            children: [
              TabBar(
                indicatorColor: Colors.yellow,
                labelStyle: TextStyle(fontFamily: 'VT323', fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: TextStyle(fontFamily: 'VT323', fontSize: 10),
                labelColor: Colors.yellow,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Image.asset('assets/progression.png'), text: 'Progression'),
                  Tab(icon: Image.asset('assets/astuce.png'), text: 'Points'),
                  Tab(icon: Image.asset('assets/speed.png'), text: 'Rapidité'),
                  Tab(icon: Image.asset('assets/probleme.png'), text: 'Problème'),
                  Tab(icon: Image.asset('assets/equation.png'), text: 'Équation'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildProgressionTab(),
                    _buildTopTenTab('points', 'Top 10 des Joueurs', 'points'),
                    _buildTopTenTab('rapidTestRecord', 'Top 10 - Rapidité', 'rapidTestRecord'),
                    _buildTopTenTab('ProblemTestRecord', 'Top 10 - Problème', 'ProblemTestRecord'),
                    _buildTopTenTab('equationTestRecord', 'Top 10 - Équations', 'equationTestRecord'),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar:CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          profile: _profile,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: _profile)), // Passez 'profile'
                );
                break;
              case 1:
              // Déjà sur l'écran des statistiques
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileDetailScreen(profile: _profile)), // Passez 'profile'
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(profile: _profile)), // Passez 'profile'
                );
                break;
            }
            setState(() {
              _selectedIndex = index;
            });
          },
        ),

      ),
    );
  }

  Widget _buildProgressionTab() {
    int currentLevel = getCurrentLevel(_profile);
    List<int> levelPercentages = [0, 15, 30, 50, 60, 70, 80, 90, 95, 98, 99];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, bottom: 0.0),
                  child: Text(
                    'Niveau Actuel',
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'VT323',
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: Text(
                    'Niveau $currentLevel',
                    style: TextStyle(
                      fontSize: 35,
                      fontFamily: 'VT323',
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: .0),
                  child: Text(
                    widget.getLevelDescription(currentLevel),
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'VT323',
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: constraints.maxHeight * 0.45, // Ajuster la hauteur du graphique
                  padding: const EdgeInsets.all(16.0),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              int userPercentile = getPercentile(_profile, currentLevel).toInt();
                              // Toujours afficher 0% et 100%
                              if (value.toInt() == 0) {
                                return Text('0%', style: TextStyle(color: Colors.white, fontFamily: 'VT323', fontSize: 13));
                              } else if (value.toInt() == 100) {
                                return Text('100%', style: TextStyle(color: Colors.white, fontFamily: 'VT323', fontSize: 13));
                              }
                              // Forcer l'affichage du pourcentage de l'utilisateur
                              if ((value.toInt() - userPercentile).abs() <= 1) {
                                return Text(
                                  '$userPercentile%',
                                  style: TextStyle(color: Colors.yellow, fontFamily: 'VT323', fontSize: 13, fontWeight: FontWeight.bold),
                                );
                              }
                              return Container(); // Ne rien afficher pour les autres valeurs
                            },
                            interval: 20, // Intervalle standard de 20%
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Désactive les titres à droite
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Désactive les titres en haut
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Transform.rotate(
                                  angle: -60 * 3.141592653589793238 / 180,
                                  child: Text(
                                    'Niveau ${value.toInt()}',
                                    style: TextStyle(color: Colors.white, fontFamily: 'VT323', fontSize: 13),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true, // Affiche les lignes horizontales
                        horizontalInterval: 10, // Ajoute des lignes horizontales à chaque 10%
                        getDrawingHorizontalLine: (value) {
                          int userPercentile = getPercentile(_profile, currentLevel).toInt();
                          if (value.toInt() == userPercentile) {
                            return FlLine(
                              color: Colors.yellow, // Ligne spéciale pour l'utilisateur
                              strokeWidth: 2,
                              dashArray: [5, 5], // Ligne en pointillés
                            );
                          }
                          return FlLine(
                            color: Colors.white70,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white70, width: 1),
                      ),
                      barGroups: levelPercentages.asMap().entries.map((entry) {
                        int level = entry.key;
                        int percentage = entry.value;
                        return BarChartGroupData(
                          x: level,
                          barRods: [
                            BarChartRodData(
                              toY: percentage.toDouble(),
                              color: level == currentLevel ? Colors.yellow : Colors.blue, // Couleurs pixelisées
                              width: 16,
                              borderRadius: BorderRadius.zero, // Suppression de l'arrondi pour un style rétro plus carré
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Vous êtes meilleur(e) que ${getPercentile(_profile, currentLevel)}% de la population',
                    style: TextStyle(fontSize: 30, fontFamily: 'VT323', color: Colors.yellow, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),



              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildTopTenTab(String field, String title, String scoreLabel) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('profiles').orderBy(field, descending: true).limit(10).get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.yellow));
        }

        // Convertir les documents Firestore en List<Map<String, dynamic>>
        List<Map<String, dynamic>> participants = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        return _buildParticipantsTable(participants, scoreLabel);
      },
    );
  }

  Widget _buildParticipantsTable(List<Map<String, dynamic>> participants, String scoreLabel) {
    // Trier les participants en fonction des points
    participants.sort((a, b) => (b[scoreLabel] ?? 0).compareTo(a[scoreLabel] ?? 0));

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
              itemCount: participants.length,
              itemBuilder: (context, index) {
                var participant = participants[index];
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
                      Image.asset(participant['flag'] ?? 'assets/default_flag.png', width: 24, height: 24),
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
                          '${participant[scoreLabel] ?? 0}', // Utilise le champ correct pour afficher le score
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

  int getCurrentLevel(AppUser profile) {
    for (int level = 10; level >= 1; level--) {
      if (profile.progression[level]!.values.every((element) => element['validation'] == 1)) {
        return level;
      }
    }
    return 0;
  }

  int getPercentile(AppUser profile, int currentLevel) {
    switch (currentLevel) {
      case 1:
        return 15;
      case 2:
        return 30;
      case 3:
        return 50;
      case 4:
        return 60;
      case 5:
        return 70;
      case 6:
        return 80;
      case 7:
        return 90;
      case 8:
        return 95;
      case 9:
        return 98;
      case 10:
        return 99;
      default:
        return 0;
    }
  }
}
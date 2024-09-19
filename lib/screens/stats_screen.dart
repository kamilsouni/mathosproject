import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mathosproject/models/app_user.dart';
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
        appBar: TopAppBar(title: 'Statistiques'),
        body: Container(
          color: Color(0xFF564560), // Fond violet
          child: Column(
            children: [
              TabBar(
                indicatorColor: Colors.yellow,
                labelStyle: TextStyle(fontFamily: 'VT323', fontWeight: FontWeight.bold, fontSize: 15), // Ajuste la taille du texte
                unselectedLabelStyle: TextStyle(fontFamily: 'VT323', fontSize: 10),
                labelColor: Colors.yellow,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: IconTheme(
                      data: IconThemeData(size: 24),
                      child: Image.asset(
                        'assets/progression.png', // Image pour l'onglet Progression
                        fit: BoxFit.contain,
                      ),
                    ),
                    text: 'Progression',
                  ),
                  Tab(
                    icon: IconTheme(
                      data: IconThemeData(size: 24),
                      child: Image.asset(
                        'assets/astuce.png', // Image pour l'onglet Points
                        fit: BoxFit.contain,
                      ),
                    ),
                    text: 'Points',
                  ),
                  Tab(
                    icon: IconTheme(
                      data: IconThemeData(size: 24),
                      child: Image.asset(
                        'assets/speed.png', // Image pour l'onglet Rapidité
                        fit: BoxFit.contain,
                      ),
                    ),
                    text: 'Rapidité',
                  ),
                  Tab(
                    icon: IconTheme(
                      data: IconThemeData(size: 24),
                      child: Image.asset(
                        'assets/probleme.png', // Image pour l'onglet Problème
                        fit: BoxFit.contain,
                      ),
                    ),
                    text: 'Problème',
                  ),
                  Tab(
                    icon: IconTheme(
                      data: IconThemeData(size: 24),
                      child: Image.asset(
                        'assets/equation.png', // Image pour l'onglet Équation
                        fit: BoxFit.contain,
                      ),
                    ),
                    text: 'Équation',
                  ),

                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildProgressionTab(),
                    _buildRankingTab(),
                    _buildRapidityRecordsTab(),
                    _buildProblemRecordsTab(),
                    _buildEquationRecordsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          profile: _profile,
          onTap: (index) {
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

  Widget _buildRankingTab() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy('points', descending: true)
          .limit(10)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.yellow));
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Top 10 des Joueurs',
                          style: TextStyle(fontSize: 40, fontFamily: 'VT323', color: Colors.yellow, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: _buildRetroTable(
                          columns: ['Rang', 'Joueur', 'Points'],
                          rows: docs.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value.data() as Map<String, dynamic>;
                            return [
                              '${index + 1}',
                              '${data['name']}',
                              '${data['points']}',
                            ];
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRapidityRecordsTab() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy('rapidTestRecord', descending: true)
          .limit(10)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.yellow));
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Top 10 - Rapidité',
                          style: TextStyle(fontSize: 40, fontFamily: 'VT323', color: Colors.yellow, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: _buildRetroTable(
                          columns: ['Rang', 'Joueur', 'Score'],
                          rows: docs.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value.data() as Map<String, dynamic>;
                            return [
                              '${index + 1}',
                              '${data['name']}',
                              '${data['rapidTestRecord'] ?? 'N/A'}',
                            ];
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProblemRecordsTab() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy('ProblemTestRecord', descending: true)
          .limit(10)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.yellow));
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Top 10 - Problème',
                          style: TextStyle(fontSize: 40, fontFamily: 'VT323', color: Colors.yellow, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: _buildRetroTable(
                          columns: ['Rang', 'Joueur', 'Score'],
                          rows: docs.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value.data() as Map<String, dynamic>;
                            return [
                              '${index + 1}',
                              '${data['name']}',
                              '${data['ProblemTestRecord'] ?? 'N/A'}',
                            ];
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEquationRecordsTab() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy('equationTestRecord', descending: true)
          .limit(10)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.yellow));
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Top 10 - Équations',
                          style: TextStyle(fontSize: 40, fontFamily: 'VT323', color: Colors.yellow, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: _buildRetroTable(
                          columns: ['Rang', 'Joueur', 'Score'],
                          rows: docs.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value.data() as Map<String, dynamic>;
                            return [
                              '${index + 1}',
                              '${data['name']}',
                              '${data['equationTestRecord'] ?? 'N/A'}',
                            ];
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRetroTable({required List<String> columns, required List<List<String>> rows}) {
    return Table(
      border: TableBorder.all(
        color: Colors.yellow,
        width: 3,
        style: BorderStyle.solid,
      ),
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.blue), // Couleur bleu foncé pour un style rétro
          children: columns.map((column) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              column,
              style: TextStyle(
                fontFamily: 'VT323',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25, // Taille du texte pour un look pixel art
              ),
              textAlign: TextAlign.center,
            ),
          )).toList(),
        ),
        ...rows.map((row) => TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[850], // Couleur sombre pour le fond des rangées
          ),
          children: row.map((cell) => Padding(
            padding: const EdgeInsets.all(7.0),
            child: Text(
              cell,
              style: TextStyle(
                fontFamily: 'VT323',
                color: Colors.yellow, // Texte jaune pour le style rétro
                fontSize: 20, // Taille du texte pour un look pixel art
              ),
              textAlign: TextAlign.center,
            ),
          )).toList(),
        )).toList(),
      ],
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

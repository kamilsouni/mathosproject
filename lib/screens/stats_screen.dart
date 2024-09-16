import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  int _selectedIndex = 1; // Index par défaut pour la barre de navigation

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Cinq onglets : Progression, Points, Rapidité, Précision, Équation
      child: Scaffold(
        appBar: TopAppBar(
          title: 'Statistiques',
          showBackButton: false,
        ),
        body: Column(
          children: [
            TabBar(

                indicatorColor: Colors.black,  // Couleur de l'indicateur sous l'onglet sélectionné
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, // Mettre le texte de l'onglet sélectionné en gras
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal, // Texte normal pour les onglets non sélectionnés
                ),
                labelColor: Colors.black,  // Couleur du texte des onglets sélectionnés
                unselectedLabelColor: Colors.black54,  // Texte grisé pour les onglets non sélectionnés
                tabs: [
                  Tab(text: 'Progression'),
                  Tab(text: 'Points'),
                  Tab(text: 'Rapidité'),
                  Tab(text: 'Précision'),
                  Tab(text: 'Équation'),
                ],
              ),





            Expanded(
              child: TabBarView(
                children: [
                  _buildProgressionTab(),
                  _buildRankingTab(),
                  _buildRapidityRecordsTab(),
                  _buildPrecisionRecordsTab(),
                  _buildEquationRecordsTab(), // Ajout de l'onglet Équation
                ],
              ),
            ),
          ],
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

  // Onglet Progression
  Widget _buildProgressionTab() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    int currentLevel = getCurrentLevel(_profile);
    List<int> levelPercentages = [0, 15, 30, 50, 60, 70, 80, 90, 95, 98, 99];

    return Stack(
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
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Niveau actuel
              Text(
                'Niveau Actuel : Niveau $currentLevel',
                style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                widget.getLevelDescription(currentLevel),
                style: TextStyle(fontSize: screenWidth * 0.045),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04),

              // Distribution des niveaux
              Text(
                'Niveau par rapport à la Population',
                style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // Centrer le texte
              ),
              SizedBox(height: screenHeight * 0.03),

              // Graphique de distribution des niveaux
              SizedBox(
                height: screenHeight * 0.3,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return Text('0%');
                              case 50:
                                return Text('50%');
                              case 100:
                                return Text('100%');
                              default:
                                return Container();
                            }
                          },
                        ),
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
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.black, width: 1),
                        bottom: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    barGroups: levelPercentages.asMap().entries.map((entry) {
                      int level = entry.key;
                      int percentage = entry.value;
                      return BarChartGroupData(
                        x: level,
                        barRods: [
                          BarChartRodData(
                            toY: percentage.toDouble(),
                            color: level == getCurrentLevel(_profile) ? Colors.red : Colors.blue,
                            width: screenWidth * 0.05,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Pourcentage de positionnement
              Text(
                'Vous êtes meilleur(e) que ${getPercentile(_profile, currentLevel)}% de la population',
                style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ],
    );
  }

  // Onglet Classement en fonction des Points
  Widget _buildRankingTab() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy('points', descending: true)
          .limit(10)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(data['flag'] ?? 'assets/default_flag.png'),
              ),
              title: Text('#${index + 1} ${data['name']}'),
              trailing: Text('${data['points']} points'),
            );
          },
        );
      },
    );
  }

  // Onglet Records pour Rapidité
  Widget _buildRapidityRecordsTab() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy('rapidTestRecord', descending: true) // Assurez-vous que ce champ est correct
          .limit(10)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(data['flag'] ?? 'assets/default_flag.png'),
              ),
              title: Text('#${index + 1} ${data['name']}'),
              trailing: Text('${data['rapidTestRecord'] ?? 'N/A'} points'),
            );
          },
        );
      },
    );
  }

  // Onglet Records pour Précision
  Widget _buildPrecisionRecordsTab() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy('precisionTestRecord', descending: true) // Assurez-vous que ce champ est correct
          .limit(10)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(data['flag'] ?? 'assets/default_flag.png'),
              ),
              title: Text('#${index + 1} ${data['name']}'),
              trailing: Text('${data['precisionTestRecord'] ?? 'N/A'} points'),
            );
          },
        );
      },
    );
  }

  // Onglet Records pour Équation
  Widget _buildEquationRecordsTab() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy('equationTestRecord', descending: true) // Trie par le record d'équation
          .limit(10) // Limite à 10 participants
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(data['flag'] ?? 'assets/default_flag.png'),
              ),
              title: Text('#${index + 1} ${data['name']}'),
              trailing: Text('${data['equationTestRecord'] ?? 'N/A'} points'),
            );
          },
        );
      },
    );
  }

  // Méthode pour obtenir le niveau actuel de l'utilisateur
  int getCurrentLevel(AppUser profile) {
    for (int level = 10; level >= 1; level--) {
      if (profile.progression[level]!.values
          .every((element) => element['validation'] == 1)) {
        return level;
      }
    }
    return 0;
  }

  // Méthode pour obtenir le pourcentage de positionnement
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

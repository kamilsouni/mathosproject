import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/profile_detail_screen.dart';
import 'package:mathosproject/screens/settings_screen.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:country_flags/country_flags.dart';

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
        return "Novice des Nombres : Félicitations, vous avez conquis les bases.";
      case 2:
        return "Apprenti Calculateur : Les additions n'ont plus de secret.";
      case 3:
        return "Maître des Multiplications : Les tables sont maîtrisées !";
      case 4:
        return "Génie des Calculs : Un véritable talent en calcul.";
      case 5:
        return "Calculateur de Compétition : Prêt pour les championnats !";
      case 6:
        return "Maître des Nombres : La maîtrise est totale.";
      case 7:
        return "Calculateur Suprême : Un niveau impressionnant.";
      case 8:
        return "Virtuose des Chiffres : Une excellence rare.";
      case 9:
        return "Seigneur des Calculs : La perfection mathématique.";
      case 10:
        return "Grand Maître des Mathématiques : Le sommet est atteint !";
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.yellow,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: TopAppBar(
          title: 'Statistiques',
          showBackButton: true,
          onBackPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ModeSelectionScreen(profile: _profile),
              ),
            );
          },
        ),
        body: Container(
          color: Color(0xFF564560),
          child: Column(
            children: [
              _buildTabBar(screenSize),
              Flexible(
                child: TabBarView(
                  children: [
                    _buildProgressionTab(screenSize),
                    _buildTopTenTab('points', 'Top 10 des Joueurs', screenSize),
                    _buildTopTenTab('rapidTestRecord', 'Top 10 - Rapidité', screenSize),
                    _buildTopTenTab('ProblemTestRecord', 'Top 10 - Problème', screenSize),
                    _buildTopTenTab('equationTestRecord', 'Top 10 - Équations', screenSize),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          profile: _profile,
          onTap: (index) => _handleNavigation(index),
        ),
      ),
    );
  }

  Widget _buildTabBar(Size screenSize) {
    final tabHeight = screenSize.height * 0.10;
    final iconSize = screenSize.height * 0.038;
    final fontSize = screenSize.height * 0.015;

    return Container(
      height: tabHeight,
      child: TabBar(
        indicatorColor: Colors.yellow,
        labelStyle: TextStyle(
          fontFamily: 'VT323',
          fontWeight: FontWeight.bold,
          fontSize: fontSize * 1.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'VT323',
          fontSize: fontSize,
        ),
        labelColor: Colors.yellow,
        unselectedLabelColor: Colors.white70,
        tabs: [
          _buildTab('progression.png', 'Progression', iconSize),
          _buildTab('dollar.png', 'Points', iconSize),
          _buildTab('speed.png', 'Rapidité', iconSize),
          _buildTab('probleme.png', 'Problème', iconSize),
          _buildTab('equation.png', 'Équation', iconSize),
        ],
      ),
    );
  }

  Widget _buildTab(String iconPath, String label, double iconSize) {
    return Tab(
      icon: Image.asset(
        'assets/$iconPath',
        height: iconSize,
      ),
      text: label,
    );
  }

  Widget _buildProgressionTab(Size screenSize) {
    final currentLevel = getCurrentLevel(_profile);
    final levelPercentages = [0, 15, 30, 50, 60, 70, 80, 90, 95, 98, 99];

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: Column(
          children: [
            _buildProgressionHeader(screenSize, currentLevel),
            _buildProgressionChart(screenSize, currentLevel, levelPercentages),
            _buildProgressionFooter(screenSize, currentLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionHeader(Size screenSize, int currentLevel) {
    return Column(
      children: [
        Text(
          'Niveau Actuel',
          style: TextStyle(
            fontSize: screenSize.height * 0.04,
            fontFamily: 'VT323',
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Niveau $currentLevel',
          style: TextStyle(
            fontSize: screenSize.height * 0.035,
            fontFamily: 'VT323',
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.04,
            vertical: screenSize.height * 0.02,
          ),
          child: Text(
            widget.getLevelDescription(currentLevel),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenSize.height * 0.02,
              fontFamily: 'VT323',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressionChart(Size screenSize, int currentLevel, List<int> levelPercentages) {
    return Container(
      height: screenSize.height * 0.4,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white70,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: _getBarChartTitles(screenSize),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white70),
          ),
          barGroups: _getBarGroups(currentLevel, levelPercentages, screenSize),
        ),
      ),
    );
  }

  FlTitlesData _getBarChartTitles(Size screenSize) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: screenSize.height * 0.05,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: EdgeInsets.only(top: screenSize.height * 0.01),
              child: Transform.rotate(
                angle: -0.5,
                child: Text(
                  'Niveau ${value.toInt() + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'VT323',
                    fontSize: screenSize.height * 0.015,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: screenSize.width * 0.1,
          interval: 20,
          getTitlesWidget: (value, meta) {
            return Text(
              '${value.toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'VT323',
                fontSize: screenSize.height * 0.015,
              ),
            );
          },
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _getBarGroups(int currentLevel, List<int> levelPercentages, Size screenSize) {
    return levelPercentages.asMap().entries.map((entry) {
      final index = entry.key;
      final percentage = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: percentage.toDouble(),
            color: index == currentLevel ? Colors.yellow : Colors.blue,
            width: screenSize.width * 0.04,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildProgressionFooter(Size screenSize, int currentLevel) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Text(
        'Vous êtes meilleur(e) que ${getPercentile(_profile, currentLevel)}% de la population',
        style: TextStyle(
          fontSize: screenSize.height * 0.025,
          fontFamily: 'VT323',
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTopTenTab(String field, String title, Size screenSize) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('profiles')
          .orderBy(field, descending: true)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.yellow));
        }

        final allParticipants = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Vérifier si l'utilisateur a un score en fonction du field
        int userScore;
        switch (field) {
          case 'rapidTestRecord':
            userScore = _profile.rapidTestRecord;
            break;
          case 'ProblemTestRecord':
            userScore = _profile.ProblemTestRecord;
            break;
          case 'equationTestRecord':
            userScore = _profile.equationTestRecord;
            break;
          case 'points':
            userScore = _profile.points;
            break;
          default:
            userScore = 0;
        }

        if (userScore == 0) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(screenSize.width * 0.04),
              child: Text(
                'Vous n\'avez pas encore de record dans ce mode.\nJouez une partie pour apparaître dans le classement !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PixelFont',
                  fontSize: screenSize.height * 0.02,
                ),
              ),
            ),
          );
        }

        return _buildParticipantsTable(allParticipants, field, screenSize);
      },
    );
  }


  Widget _buildParticipantsTable(List<Map<String, dynamic>> allParticipants, String scoreLabel, Size screenSize) {
    // Trier les participants par score
    allParticipants.sort((a, b) => (b[scoreLabel] ?? 0).compareTo(a[scoreLabel] ?? 0));

    // Trouver la position de l'utilisateur actuel
    final userIndex = allParticipants.indexWhere((p) => p['id'] == _profile.id);

    // Préparer la liste des participants à afficher
    List<Map<String, dynamic>> displayParticipants = [];
    bool addedSeparator = false;

    if (userIndex < 9) {
      // L'utilisateur est dans le top 9, afficher simplement le top 10
      displayParticipants = allParticipants.take(10).toList();
    } else {
      // Afficher le top 9, puis l'utilisateur
      displayParticipants = allParticipants.take(9).toList();
      displayParticipants.add({'isSeparator': true});
      displayParticipants.add(allParticipants[userIndex]);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.yellow, width: 2),
        borderRadius: BorderRadius.circular(screenSize.width * 0.02),
      ),
      margin: EdgeInsets.all(screenSize.width * 0.020),
      child: Column(
        children: [
          // En-tête
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.02),
            child: Text(
              'CLASSEMENT',
              style: TextStyle(
                color: Colors.yellow,
                fontFamily: 'PixelFont',
                fontSize: screenSize.height * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Liste des participants
          Expanded(
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(), // Désactive le défilement
              itemCount: displayParticipants.length,
              itemBuilder: (context, index) {
                final participant = displayParticipants[index];

                // Afficher les points de séparation
                if (participant['isSeparator'] == true) {
                  return Container(
                    height: screenSize.height * 0.05,
                    child: Center(
                      child: Text(
                        '...',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: screenSize.height * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                // Calculer la vraie position
                final realPosition = allParticipants.indexWhere((p) => p['id'] == participant['id']) + 1;
                return _buildParticipantRow(participant, realPosition, scoreLabel, screenSize);
              },
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildParticipantRow(Map<String, dynamic> participant, int position, String scoreLabel, Size screenSize) {
    final bool isCurrentUser = participant['id'] == _profile.id;
    final rowHeight = screenSize.height * 0.06; // Hauteur fixe pour chaque ligne

    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.yellow.withOpacity(0.1) : null,
        border: Border(
          bottom: BorderSide(color: Colors.yellow.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: screenSize.width * 0.02),
          _buildRankingCircle(position, screenSize),
          SizedBox(width: screenSize.width * 0.02),
          _buildCountryFlag(participant['flag'] ?? 'XX', screenSize),
          SizedBox(width: screenSize.width * 0.02),
          _buildParticipantName(participant['name'] ?? 'Inconnu', screenSize),
          _buildScoreBadge(participant[scoreLabel] ?? 0, screenSize),
          SizedBox(width: screenSize.width * 0.02),
        ],
      ),
    );
  }


  Widget _buildRankingCircle(int position, Size screenSize) {
    // Calculer la taille du cercle en fonction de la taille du texte
    final String positionText = position.toString();
    final double fontSize = positionText.length > 1
        ? screenSize.height * 0.016
        : screenSize.height * 0.02;
    final double circleSize = screenSize.width * 0.07;

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: Colors.yellow,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.01),
            child: Text(
              '$position',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'PixelFont',
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryFlag(String countryCode, Size screenSize) {
    return CountryFlag.fromCountryCode(
      countryCode,
      height: screenSize.height * 0.03,
      width: screenSize.width * 0.06,
    );
  }

  Widget _buildParticipantName(String name, Size screenSize) {
    return Expanded(
      child: Text(
        name,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'PixelFont',
          fontSize: screenSize.height * 0.02,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildScoreBadge(int score, Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.02,
        vertical: screenSize.height * 0.005,
      ),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
      ),
      child: Text(
        '$score',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'PixelFont',
          fontSize: screenSize.height * 0.018,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ModeSelectionScreen(profile: _profile),
          ),
        );
        break;
      case 1:
      // Déjà sur l'écran des statistiques
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(profile: _profile),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(profile: _profile),
          ),
        );
        break;
    }
  }

  int getCurrentLevel(AppUser profile) {
    for (int level = 10; level >= 1; level--) {
      if (profile.progression[level]!.values
          .every((element) => element['validation'] == 1)) {
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

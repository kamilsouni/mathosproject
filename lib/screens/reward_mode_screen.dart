import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';

class RewardModeScreen extends StatelessWidget {
  final AppUser profile;

  RewardModeScreen({required this.profile});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopAppBar(title: 'Récompenses et Astuces', showBackButton: true),
      body: Container(
        color: Color(0xFF564560), // Fond violet
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    int level = index + 1;
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.yellow, width: 2),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Niveau $level',
                              style: TextStyle(
                                fontFamily: 'PixelFont',
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTipButton(context, 'Addition', level, screenWidth, screenHeight),
                                _buildTipButton(context, 'Soustraction', level, screenWidth, screenHeight),
                                _buildTipButton(context, 'Multiplication', level, screenWidth, screenHeight),
                                _buildTipButton(context, 'Division', level, screenWidth, screenHeight),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipButton(BuildContext context, String operation, int level, double screenWidth, double screenHeight) {
    bool isAccessible = profile.progression[level]?[operation]?['validation'] == 1;

    Color buttonColor = isAccessible ? Colors.yellow.withOpacity(0.7) : Colors.grey;
    String buttonText = _getOperationSymbol(operation);

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: isAccessible
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TipDetailScreen(level: level, operation: operation),
              ),
            );
          }
              : null,
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  String _getOperationSymbol(String operation) {
    switch (operation) {
      case 'Addition':
        return '+';
      case 'Soustraction':
        return '-';
      case 'Multiplication':
        return '×';
      case 'Division':
        return '÷';
      default:
        return operation.substring(0, 1);
    }
  }
}




class TipDetailScreen extends StatelessWidget {
  final int level;
  final String operation;

  TipDetailScreen({required this.level, required this.operation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopAppBar(title: 'Astuce', showBackButton: true),
      body: Container(
        color: Color(0xFF564560), // Fond violet
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '$operation - Niveau $level',
                          style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: constraints.maxWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        Container(
                          height: constraints.maxHeight * 0.7, // 70% de la hauteur de l'écran
                          child: _getTipContent(level, operation, constraints),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTipContent(String content, BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.all(constraints.maxWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(color: Colors.yellow, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: AutoSizeText(
          content,
          style: TextStyle(
            fontFamily: 'VT323',
            color: Colors.white,
          ),
          minFontSize: 20,
          maxFontSize: 45,
          stepGranularity: 1,
          maxLines: 20, // Ajustez ce nombre selon vos besoins
        ),
      ),
    );
  }

  Widget _getTipContent(int level, String operation, BoxConstraints constraints) {
    String content;
    switch (operation) {
      case 'Addition':
        content = _getAdditionTip(level);
        break;
      case 'Soustraction':
        content = _getSubtractionTip(level);
        break;
      case 'Multiplication':
        content = _getMultiplicationTip(level);
        break;
      case 'Division':
        content = _getDivisionTip(level);
        break;
      default:
        content = 'Astuces à venir.';
    }
    return _buildTipContent(content, constraints);
  }



  String _getAdditionTip(int level) {
    String content;
    switch (level) {
      case 1:
        content = '### Utilisez la commutativité pour les additions\n\n'
            'En addition, l\'ordre des nombres n\'affecte pas le résultat. '
            'Cela signifie que si vous avez une addition à faire, vous pouvez '
            'changer l\'ordre des termes pour rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- 3 + 5 est le même que 5 + 3\n'
            '- 2 + 7 est le même que 7 + 2';
        break;
      case 2:
        content = '### Décomposez les nombres pour simplifier les additions\n\n'
            'Décomposer les nombres en parties plus petites peut rendre '
            'l\'addition plus facile. Par exemple, vous pouvez décomposer '
            'un nombre en dizaines et unités.\n\n'
            '**Exemples:**\n'
            '- 14 + 9 peut être décomposé en 14 + 6 + 3 = 20 + 3 = 23\n'
            '- 27 + 18 peut être décomposé en 20 + 7 + 10 + 8 = 30 + 15 = 45';
        break;
      case 3:
        content = '### Ajoutez d\'abord les dizaines, puis les unités\n\n'
            'Pour rendre l\'addition plus simple, commencez par ajouter les dizaines '
            'et ensuite les unités.\n\n'
            '**Exemples:**\n'
            '- 25 + 37 = 20 + 30 = 50, puis 5 + 7 = 12, donc 50 + 12 = 62\n'
            '- 48 + 26 = 40 + 20 = 60, puis 8 + 6 = 14, donc 60 + 14 = 74';
        break;
      case 4:
        content =
        '### Utilisez les compléments pour simplifier les additions\n\n'
            'Les compléments à 10 peuvent aider à rendre les additions plus faciles. '
            'Trouvez le complément de l\'un des nombres pour simplifier l\'addition.\n\n'
            '**Exemples:**\n'
            '- 9 + 6 = 9 + 1 + 5 = 15\n'
            '- 8 + 7 = 8 + 2 + 5 = 15';
        break;
      case 5:
        content = '### Regroupez les nombres pour faciliter l\'addition\n\n'
            'Regroupez les nombres pour former des multiples de 10 ou 100. '
            'Cela peut rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- 34 + 66 = 30 + 4 + 60 + 6 = 90 + 10 = 100\n'
            '- 56 + 44 = 50 + 6 + 40 + 4 = 90 + 10 = 100';
        break;
      case 6:
        content =
        '### Utilisez des astuces pour additionner rapidement de grands nombres\n\n'
            'Pour additionner de grands nombres, arrondissez-les d\'abord et ajustez ensuite.\n\n'
            '**Exemples:**\n'
            '- 398 + 564 = arrondir à 400 + 560 = 960, puis ajustez en soustrayant 2 et ajoutant 4, donc 962\n'
            '- 723 + 489 = arrondir à 720 + 490 = 1210, puis ajustez en ajoutant 3 et soustrayant 1, donc 1212';
        break;
      case 7:
        content =
        '### Décomposez les nombres complexes en parties plus simples\n\n'
            'Décomposez les grands nombres en centaines, dizaines et unités pour simplifier l\'addition.\n\n'
            '**Exemples:**\n'
            '- 123 + 456 = 100 + 400 = 500, puis 20 + 50 = 70, et 3 + 6 = 9, donc 500 + 70 + 9 = 579\n'
            '- 234 + 567 = 200 + 500 = 700, puis 30 + 60 = 90, et 4 + 7 = 11, donc 700 + 90 + 11 = 801';
        break;
      case 8:
        content =
        '### Utilisez les propriétés des nombres pour additionner plus facilement\n\n'
            'Combinez des nombres pour former des multiples de 10 ou 100 pour simplifier l\'addition.\n\n'
            '**Exemples:**\n'
            '- 48 + 25 + 32 = (48 + 32) + 25 = 80 + 25 = 105\n'
            '- 57 + 43 + 20 = (57 + 43) + 20 = 100 + 20 = 120';
        break;
      case 9:
        content =
        '### Apprenez les techniques de calcul mental pour additionner rapidement\n\n'
            'Utilisez des techniques comme l\'addition partielle pour simplifier les calculs.\n\n'
            '**Exemples:**\n'
            '- 145 + 278 = 145 + 280 = 425, puis soustrayez 2 pour obtenir 423\n'
            '- 365 + 128 = 365 + 130 = 495, puis soustrayez 2 pour obtenir 493';
        break;
      case 10:
        content =
        '### Utilisez les techniques avancées pour additionner de grands nombres\n\n'
            'Combinez plusieurs techniques de calcul mental pour additionner rapidement de grands nombres.\n\n'
            '**Exemples:**\n'
            '- 999 + 876 = 1000 + 876 = 1876, puis soustrayez 1 pour obtenir 1875\n'
            '- 784 + 536 = 780 + 540 = 1320, puis ajoutez 4 et soustrayez 4 pour obtenir 1320';
        break;
      default:
        content = 'Astuces à venir.';
    }

    return content;

}

  String _getSubtractionTip(int level) {
    String content;
    switch (level) {
      case 1:
        content = '### Utilisez les compléments à 10 pour les soustractions\n\n'
            'Les compléments à 10 peuvent aider à rendre les soustractions plus faciles. '
            'Par exemple, trouvez le complément de l\'un des nombres pour simplifier la soustraction.\n\n'
            '**Exemples:**\n'
            '- 13 - 7, pensez à 10 - 7 = 3, puis 3 + 3 = 6\n'
            '- 15 - 8, pensez à 10 - 8 = 2, puis 2 + 5 = 7';
        break;
      case 2:
        content = '### Soustrayez d\'abord les dizaines, puis les unités\n\n'
            'Pour rendre la soustraction plus simple, commencez par soustraire les dizaines '
            'et ensuite les unités.\n\n'
            '**Exemples:**\n'
            '- 57 - 23, soustrayez 50 - 20 = 30, puis 7 - 3 = 4, et ajoutez 30 + 4 = 34\n'
            '- 84 - 26, soustrayez 80 - 20 = 60, puis 4 - 6 = -2, donc 60 - 2 = 58';
        break;
      case 3:
        content =
        '### Décomposez les nombres pour simplifier les soustractions\n\n'
            'Décomposer les nombres en parties plus petites peut rendre '
            'la soustraction plus facile. Par exemple, vous pouvez décomposer '
            'un nombre en dizaines et unités.\n\n'
            '**Exemples:**\n'
            '- 84 - 29, décomposez 84 en 80 + 4 et 29 en 20 + 9. Soustrayez 80 - 20 = 60 et 4 - 9 = -5, donc 60 - 5 = 55\n'
            '- 95 - 37, décomposez 95 en 90 + 5 et 37 en 30 + 7. Soustrayez 90 - 30 = 60 et 5 - 7 = -2, donc 60 - 2 = 58';
        break;
      case 4:
        content =
        '### Utilisez les propriétés des nombres pour simplifier les soustractions\n\n'
            'Les propriétés des nombres peuvent aider à simplifier la soustraction. '
            'Par exemple, pensez à des nombres ronds pour rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- 92 - 47, pensez à 100 - 47 = 53, puis soustrayez 8 pour obtenir 45\n'
            '- 81 - 36, pensez à 80 - 36 = 44, puis ajoutez 1 pour obtenir 45';
        break;
      case 5:
        content = '### Regroupez les nombres pour faciliter la soustraction\n\n'
            'Regroupez les nombres pour former des multiples de 10 ou 100. '
            'Cela peut rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- 156 - 78, décomposez en 156 - 80 + 2 = 76 + 2 = 78\n'
            '- 234 - 56, décomposez en 230 - 50 = 180, puis ajoutez 4 pour obtenir 184';
        break;
      case 6:
        content =
        '### Utilisez des astuces pour soustraire rapidement de grands nombres\n\n'
            'Pour soustraire de grands nombres, arrondissez-les d\'abord et ajustez ensuite.\n\n'
            '**Exemples:**\n'
            '- 745 - 389, arrondissez à 750 - 390 = 360, puis ajustez en ajoutant 5 et 1, ce qui donne 356\n'
            '- 678 - 432, arrondissez à 680 - 430 = 250, puis ajustez en soustrayant 2 et 2, ce qui donne 246';
        break;
      case 7:
        content =
        '### Décomposez les nombres complexes en parties plus simples\n\n'
            'Décomposez les grands nombres en centaines, dizaines et unités pour simplifier la soustraction.\n\n'
            '**Exemples:**\n'
            '- 432 - 216, décomposez en 400 - 200 = 200, 30 - 10 = 20, 2 - 6 = -4. Ajoutez 200 + 20 - 4 = 216\n'
            '- 567 - 289, décomposez en 500 - 200 = 300, 60 - 80 = -20, 7 - 9 = -2. Ajoutez 300 - 20 - 2 = 278';
        break;
      case 8:
        content =
        '### Utilisez les propriétés des nombres pour soustraire plus facilement\n\n'
            'Les propriétés des nombres peuvent aider à simplifier la soustraction. '
            'Par exemple, pensez à des nombres ronds pour rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- 123 - 45 - 23, regroupez comme 123 - 23 - 45 = 100 - 45 = 55\n'
            '- 234 - 56 - 78, regroupez comme 234 - 34 - 56 = 200 - 56 = 144';
        break;
      case 9:
        content =
        '### Apprenez les techniques de calcul mental pour soustraire rapidement\n\n'
            'Utilisez des techniques comme la soustraction partielle pour simplifier les calculs.\n\n'
            '**Exemples:**\n'
            '- 185 - 67, vous pouvez d\'abord faire 185 - 70 = 115, puis ajouter 3 pour obtenir 118\n'
            '- 294 - 87, vous pouvez d\'abord faire 294 - 90 = 204, puis ajouter 3 pour obtenir 207';
        break;
      case 10:
        content =
        '### Utilisez les techniques avancées pour soustraire de grands nombres\n\n'
            'Combinez plusieurs techniques de calcul mental pour soustraire rapidement de grands nombres.\n\n'
            '**Exemples:**\n'
            '- 1000 - 876, arrondissez à 1000 - 900 = 100, puis ajoutez 24 pour obtenir 124\n'
            '- 789 - 654, arrondissez à 790 - 650 = 140, puis soustrayez 1 et 4 pour obtenir 135';
        break;
      default:
        content = 'Astuces à venir.';
    }
    return content;
  }

  String _getMultiplicationTip(int level) {
    String content;
    switch (level) {
      case 1:
        content = '### Apprenez les tables de multiplication de base\n\n'
            'Les tables de multiplication sont essentielles pour des calculs rapides. '
            'Mémorisez les multiplications de base pour gagner du temps.\n\n'
            '**Exemples:**\n'
            '- 7 × 8 = 56\n'
            '- 6 × 9 = 54';
        break;
      case 2:
        content =
        '### Utilisez des multiples connus pour simplifier la multiplication\n\n'
            'Utiliser des multiples connus comme 10, 5 ou 2 peut simplifier les calculs.\n\n'
            '**Exemples:**\n'
            '- 14 × 5 peut être vu comme 14 × 10 / 2 = 70\n'
            '- 18 × 5 peut être vu comme 18 × 10 / 2 = 90';
        break;
      case 3:
        content =
        '### Décomposez les nombres pour faciliter la multiplication\n\n'
            'Décomposer les nombres en parties plus petites peut rendre '
            'la multiplication plus facile. Par exemple, vous pouvez décomposer '
            'un nombre en dizaines et unités.\n\n'
            '**Exemples:**\n'
            '- 23 × 4 peut être décomposé en 20 × 4 = 80 et 3 × 4 = 12. Ajoutez 80 + 12 = 92\n'
            '- 36 × 5 peut être décomposé en 30 × 5 = 150 et 6 × 5 = 30. Ajoutez 150 + 30 = 180';
        break;
      case 4:
        content =
        '### Utilisez les propriétés des nombres pour multiplier plus facilement\n\n'
            'Les propriétés des nombres peuvent aider à simplifier la multiplication. '
            'Par exemple, pensez à des nombres ronds pour rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- 27 × 6 peut être vu comme (20 + 7) × 6 = 120 + 42 = 162\n'
            '- 48 × 5 peut être vu comme (50 - 2) × 5 = 250 - 10 = 240';
        break;
      case 5:
        content = '### Multipliez les dizaines, puis les unités\n\n'
            'Pour rendre la multiplication plus simple, commencez par multiplier les dizaines '
            'et ensuite les unités.\n\n'
            '**Exemples:**\n'
            '- 34 × 12 peut être vu comme 30 × 10 + 30 × 2 + 4 × 10 + 4 × 2 = 300 + 60 + 40 + 8 = 408\n'
            '- 56 × 14 peut être vu comme 50 × 10 + 50 × 4 + 6 × 10 + 6 × 4 = 500 + 200 + 60 + 24 = 784';
        break;
      case 6:
        content =
        '### Utilisez des astuces pour multiplier rapidement de grands nombres\n\n'
            'Pour multiplier de grands nombres, arrondissez-les d\'abord et ajustez ensuite.\n\n'
            '**Exemples:**\n'
            '- 99 × 5 peut être vu comme 100 × 5 - 5 = 500 - 5 = 495\n'
            '- 98 × 7 peut être vu comme 100 × 7 - 2 × 7 = 700 - 14 = 686';
        break;
      case 7:
        content =
        '### Décomposez les nombres complexes en parties plus simples\n\n'
            'Décomposez les grands nombres en centaines, dizaines et unités pour simplifier la multiplication.\n\n'
            '**Exemples:**\n'
            '- 123 × 7 peut être décomposé en 100 × 7 = 700, 20 × 7 = 140, 3 × 7 = 21. Ajoutez 700 + 140 + 21 = 861\n'
            '- 234 × 6 peut être décomposé en 200 × 6 = 1200, 30 × 6 = 180, 4 × 6 = 24. Ajoutez 1200 + 180 + 24 = 1404';
        break;
      case 8:
        content =
        '### Utilisez les propriétés des nombres pour multiplier plus facilement\n\n'
            'Les propriétés des nombres peuvent aider à simplifier la multiplication. '
            'Par exemple, pensez à des nombres ronds pour rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- 56 × 25 peut être vu comme 56 × (100 / 4) = 5600 / 4 = 1400\n'
            '- 72 × 25 peut être vu comme 72 × (100 / 4) = 7200 / 4 = 1800';
        break;
      case 9:
        content =
        '### Apprenez les techniques de calcul mental pour multiplier rapidement\n\n'
            'Utilisez des techniques comme la multiplication partielle pour simplifier les calculs.\n\n'
            '**Exemples:**\n'
            '- 123 × 11 peut être décomposé en 123 × 10 + 123 = 1230 + 123 = 1353\n'
            '- 45 × 21 peut être décomposé en 45 × 20 + 45 = 900 + 45 = 945';
        break;
      case 10:
        content =
        '### Utilisez les techniques avancées pour multiplier de grands nombres\n\n'
            'Combinez plusieurs techniques de calcul mental pour multiplier rapidement de grands nombres.\n\n'
            '**Exemples:**\n'
            '- 987 × 99 peut être vu comme 987 × (100 - 1) = 98700 - 987 = 97713\n'
            '- 456 × 98 peut être vu comme 456 × (100 - 2) = 45600 - 912 = 44688';
        break;
      default:
        content = 'Astuces à venir.';
    }
    return content;
  }

  String _getDivisionTip(int level) {
    String content;
    switch (level) {
      case 1:
        content =
        '### Utilisez les relations de multiplication pour la division\n\n'
            'Les relations entre multiplication et division peuvent aider à simplifier les calculs. '
            'Par exemple, trouvez le nombre qui, multiplié par le diviseur, donne le dividende.\n\n'
            '**Exemples:**\n'
            '- Pour 36 ÷ 6, trouvez le nombre qui, multiplié par 6, donne 36. C\'est 6\n'
            '- Pour 45 ÷ 9, trouvez le nombre qui, multiplié par 9, donne 45. C\'est 5';
        break;
      case 2:
        content = '### Divisez d\'abord les dizaines, puis les unités\n\n'
            'Pour rendre la division plus simple, commencez par diviser les dizaines '
            'et ensuite les unités.\n\n'
            '**Exemples:**\n'
            '- Pour 84 ÷ 4, divisez 80 ÷ 4 = 20 et 4 ÷ 4 = 1. Ajoutez 20 + 1 = 21\n'
            '- Pour 72 ÷ 6, divisez 70 ÷ 6 = 10 et 2 ÷ 6 = 0.33. Ajoutez 10 + 0.33 = 10.33';
        break;
      case 3:
        content = '### Décomposez les nombres pour faciliter la division\n\n'
            'Décomposer les nombres en parties plus petites peut rendre '
            'la division plus facile. Par exemple, vous pouvez décomposer '
            'un nombre en dizaines et unités.\n\n'
            '**Exemples:**\n'
            '- Pour 91 ÷ 7, décomposez en 70 ÷ 7 = 10 et 21 ÷ 7 = 3. Ajoutez 10 + 3 = 13\n'
            '- Pour 81 ÷ 9, décomposez en 80 ÷ 9 = 8.88 et 1 ÷ 9 = 0.11. Ajoutez 8.88 + 0.11 = 9';
        break;
      case 4:
        content =
        '### Utilisez les propriétés des nombres pour diviser plus facilement\n\n'
            'Les propriétés des nombres peuvent aider à simplifier la division. '
            'Par exemple, pensez à des nombres ronds pour rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- Pour 144 ÷ 12, pensez à 144 = 12 × 12, donc la réponse est 12\n'
            '- Pour 225 ÷ 15, pensez à 225 = 15 × 15, donc la réponse est 15';
        break;
      case 5:
        content = '### Regroupez les nombres pour faciliter la division\n\n'
            'Regroupez les nombres pour former des multiples de 10 ou 100. '
            'Cela peut rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- Pour 156 ÷ 12, divisez 150 ÷ 12 = 12.5, puis ajustez pour obtenir 13\n'
            '- Pour 245 ÷ 7, divisez 240 ÷ 7 = 34.28, puis ajustez pour obtenir 35';
        break;
      case 6:
        content =
        '### Utilisez des astuces pour diviser rapidement de grands nombres\n\n'
            'Pour diviser de grands nombres, arrondissez-les d\'abord et ajustez ensuite.\n\n'
            '**Exemples:**\n'
            '- Pour 745 ÷ 5, arrondissez à 750 ÷ 5 = 150, puis ajustez en soustrayant 1 pour obtenir 149\n'
            '- Pour 986 ÷ 3, arrondissez à 990 ÷ 3 = 330, puis ajustez en soustrayant 4 ÷ 3 = 1.33 pour obtenir 328.67';
        break;
      case 7:
        content =
        '### Décomposez les nombres complexes en parties plus simples\n\n'
            'Décomposez les grands nombres en centaines, dizaines et unités pour simplifier la division.\n\n'
            '**Exemples:**\n'
            '- Pour 432 ÷ 6, décomposez en 420 ÷ 6 = 70, 12 ÷ 6 = 2. Ajoutez 70 + 2 = 72\n'
            '- Pour 546 ÷ 7, décomposez en 540 ÷ 7 = 77.14, 6 ÷ 7 = 0.86. Ajoutez 77.14 + 0.86 = 78';
        break;
      case 8:
        content =
        '### Utilisez les propriétés des nombres pour diviser plus facilement\n\n'
            'Les propriétés des nombres peuvent aider à simplifier la division. '
            'Par exemple, pensez à des nombres ronds pour rendre le calcul plus facile.\n\n'
            '**Exemples:**\n'
            '- Pour 123 ÷ 3, décomposez en 120 ÷ 3 = 40 et 3 ÷ 3 = 1. Ajoutez 40 + 1 = 41\n'
            '- Pour 234 ÷ 6, décomposez en 230 ÷ 6 = 38.33 et 4 ÷ 6 = 0.67. Ajoutez 38.33 + 0.67 = 39';
        break;
      case 9:
        content =
        '### Apprenez les techniques de calcul mental pour diviser rapidement\n\n'
            'Utilisez des techniques comme la division partielle pour simplifier les calculs.\n\n'
            '**Exemples:**\n'
            '- Pour 185 ÷ 5, divisez d\'abord 1850 ÷ 50 = 37\n'
            '- Pour 294 ÷ 7, divisez d\'abord 280 ÷ 7 = 40, puis ajoutez 14 ÷ 7 = 2, donc 40 + 2 = 42';
        break;
      case 10:
        content =
        '### Utilisez les techniques avancées pour diviser de grands nombres\n\n'
            'Combinez plusieurs techniques de calcul mental pour diviser rapidement de grands nombres.\n\n'
            '**Exemples:**\n'
            '- Pour 1000 ÷ 25, arrondissez à 1000 ÷ 25 = 40\n'
            '- Pour 987 ÷ 21, arrondissez à 980 ÷ 20 = 49, puis ajustez en divisant 7 ÷ 21 = 0.33 pour obtenir 49.33';
        break;
      default:
        content = 'Astuces à venir.';
    }
    return content;
  }
}
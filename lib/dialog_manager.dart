import 'package:flutter/material.dart';
import 'sound_manager.dart'; // Import du SoundManager

class DialogManager {
  // Méthode générale pour afficher un dialogue avec personnalisation de couleur du bouton
  static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    required Color buttonColor, // Paramètre pour la couleur du bouton
  }) async {
    await SoundManager.playDialogOpenSound();
    final Size screenSize = MediaQuery.of(context).size;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Bordure carrée pour style pixel art
            side: BorderSide(color: Colors.yellow, width: 4), // Bordure jaune
          ),
          backgroundColor: Color(0xFF564560), // Fond violet
          child: Stack(
            children: [
              // Contenu du dialogue
              Container(
                width: screenSize.width * 0.8,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.yellow,
                        fontFamily: 'PixelFont',
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Contenu
                    Text(
                      content,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'PixelFont',
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                    SizedBox(height: 30),

                    // Bouton "Confirmer" avec couleur personnalisée
                    Center(
                      child: Container(
                        width: screenSize.width * 0.5,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.yellow, width: 3),
                          color: buttonColor,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await SoundManager.playYesButtonSound();
                              onConfirm();
                              Navigator.of(context).pop();
                            },
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  confirmText,
                                  style: TextStyle(
                                    color: Color(0xFF564560),
                                    fontFamily: 'PixelFont',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton "Retour" avec X en haut à droite
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () async {
                    await SoundManager.playNoButtonSound();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'X',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontFamily: 'PixelFont',
                      fontSize: screenSize.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Méthode pour afficher un dialogue avec widget intégré et personnalisation de couleur du bouton
  static Future<T?> showCustomDialogWithWidget<T>({
    required BuildContext context,
    required String title,
    required Widget contentWidget,
    required String confirmText,
    required VoidCallback onConfirm,
    required Color buttonColor, // Paramètre pour la couleur du bouton
  }) async {
    await SoundManager.playDialogOpenSound();
    final Size screenSize = MediaQuery.of(context).size;

    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Bordure carrée pour style pixel art
            side: BorderSide(color: Colors.yellow, width: 4), // Bordure jaune
          ),
          backgroundColor: Color(0xFF564560), // Fond violet
          child: Stack(
            children: [
              // Contenu du dialogue avec widget personnalisé
              Container(
                width: screenSize.width * 0.8,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'PixelFont',
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Widget personnalisé comme contenu
                    contentWidget,
                    SizedBox(height: 30),

                    // Bouton "Confirmer" avec couleur personnalisée
                    Center(
                      child: Container(
                        width: screenSize.width * 0.5,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 3),
                          color: buttonColor,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await SoundManager.playYesButtonSound();
                              onConfirm();
                              Navigator.of(context).pop();
                            },
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  confirmText,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'PixelFont',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton "Retour" avec X en haut à droite
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () async {
                    await SoundManager.playNoButtonSound();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'X',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontFamily: 'PixelFont',
                      fontSize: screenSize.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  static Future<void> showTutorialDialog({
    required BuildContext context,
    required String title,
    required VoidCallback onConfirm,
    required Color buttonColor,
  }) async {
    await SoundManager.playDialogOpenSound();
    final Size screenSize = MediaQuery.of(context).size;
    final double fontSize = screenSize.width * 0.032;
    bool dontShowAgain = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: Colors.yellow, width: 4),
              ),
              backgroundColor: Color(0xFF564560),
              child: Stack(
                children: [
                  Container(
                    width: screenSize.width * 0.8,
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height * 0.8,
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.yellow,
                            fontFamily: 'PixelFont',
                            fontSize: fontSize * 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Voici les différents modes disponibles :',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'PixelFont',
                                    fontSize: fontSize,
                                  ),
                                ),
                                SizedBox(height: 15),
                                _buildModeDescription(
                                  '1. Mode Progression 🎯',
                                  'Idéal pour commencer, ce mode permet apprentissage progressif niveau par niveau. Complétez chaque niveau pour débloquer des astuces de calcul.',
                                  fontSize,
                                ),
                                _buildModeDescription(
                                  '2. Mode Rapidité ⚡',
                                  "Entraînez votre rapidité de calcul, il faut répondre à un maximum de questions en 60 secondes. La vitesse et la précision sont essentielles.",
                                  fontSize,
                                ),

                                _buildModeDescription(
                                  '3. Mode Problème 🧩',
                                  'Résolvez des problèmes mathématiques variés en 2 minutes. Un excellent exercice pour développer votre raisonnement logique.',
                                  fontSize,
                                ),
                                _buildModeDescription(
                                  '4. Mode Équation ➗',
                                  'Retrouvez les éléments manquants dans différentes équations. Une bonne façon de renforcer votre compréhension des opérations.',
                                  fontSize,
                                ),
                                _buildModeDescription(
                                  '5. Mode Compétition 🏆',
                                  'Mesurez-vous à vos amis dans une compétition créée sur mesure.',
                                  fontSize,
                                ),
                                SizedBox(height: 15),
                                                           ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: Checkbox(
                                value: dontShowAgain,
                                onChanged: (value) {
                                  setState(() {
                                    dontShowAgain = value ?? false;
                                  });
                                },
                                fillColor: MaterialStateProperty.resolveWith(
                                      (states) => Colors.yellow,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Ne plus afficher ce message',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'PixelFont',
                                  fontSize: fontSize * 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: screenSize.width * 0.5,
                            height: 45,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.yellow, width: 3),
                              color: buttonColor,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await SoundManager.playYesButtonSound();
                                  if (dontShowAgain) {
                                    onConfirm();  // On appelle onConfirm uniquement si la case est cochée
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Center(
                                  child: Text(
                                    'Commencer',
                                    style: TextStyle(
                                      color: Color(0xFF564560),
                                      fontFamily: 'PixelFont',
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        await SoundManager.playNoButtonSound();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'X',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontFamily: 'PixelFont',
                          fontSize: screenSize.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildModeDescription(String title, String description, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.yellow,
            fontFamily: 'PixelFont',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          description,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PixelFont',
            fontSize: fontSize * 0.9,
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}




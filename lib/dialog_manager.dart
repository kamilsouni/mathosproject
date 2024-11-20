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
                        fontSize: screenSize.width * 0.05,
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
}

import 'package:flutter/material.dart';
import 'sound_manager.dart';  // Import du SoundManager

class DialogManager {

  // Méthode pour afficher un dialogue avec du texte uniquement
  static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) async {
    // Jouer le son d'ouverture du dialogue
    await SoundManager.playDialogOpenSound();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF564560),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.yellow,
              fontFamily: 'PixelFont',
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'PixelFont',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await SoundManager.playNoButtonSound(); // Jouer le son "no_button"
                Navigator.of(context).pop();  // Fermer le dialogue
              },
              child: Text(
                cancelText,
                style: TextStyle(color: Colors.white, fontFamily: 'PixelFont'),
              ),
            ),
            TextButton(
              onPressed: () async {
                await SoundManager.playYesButtonSound();  // Jouer le son pour le bouton OK
                onConfirm();  // Exécuter l'action associée
                Navigator.of(context).pop();  // Fermer le dialogue
              },
              child: Text(
                confirmText,
                style: TextStyle(color: Colors.red, fontFamily: 'PixelFont'),
              ),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher un dialogue avec un widget personnalisé
  static Future<T?> showCustomDialogWithWidget<T>({
    required BuildContext context,
    required String title,
    required Widget contentWidget,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF564560),  // Appliquer la même couleur de fond
          title: Text(
            title,
            style: TextStyle(
              color: Colors.yellow,
              fontFamily: 'PixelFont',
            ),
          ),
          content: contentWidget,  // Contenu dynamique
          actions: <Widget>[
            TextButton(
              child: Text(
                cancelText,
                style: TextStyle(color: Colors.white, fontFamily: 'PixelFont'),
              ),
              onPressed: () {
                Navigator.of(context).pop();  // Fermer le dialogue
              },
            ),
            TextButton(
              child: Text(
                confirmText,
                style: TextStyle(color: Colors.red, fontFamily: 'PixelFont'),
              ),
              onPressed: onConfirm,  // Exécuter l'action associée
            ),
          ],
        );
      },
    );
  }
}

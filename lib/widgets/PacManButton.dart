import 'package:flutter/material.dart';

// Widget personnalisé pour les boutons style Pac-Man
class PacManButton extends StatelessWidget {
  final String text; // Texte du bouton
  final VoidCallback onPressed; // Fonction à exécuter lors du clic
  final bool isLoading; // Indicateur pour afficher un chargement

  const PacManButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Taille du bouton en fonction de l'écran
    double buttonWidth = screenWidth * 0.8;
    double buttonHeight = screenHeight * 0.1;

    // Calcul de la taille de la police en fonction de la hauteur du bouton
    double fontSize = buttonHeight * 0.2; // Ajustez ce facteur si nécessaire

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, // Désactiver le bouton si en chargement
      child: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      )
          : Center(
        child: Text(
          text,
          textAlign: TextAlign.center, // Centrer le texte horizontalement
          style: TextStyle(
            fontFamily: 'PixelFont', // Style pixel art
            fontSize: fontSize, // Taille du texte adaptée à la taille du bouton
            color: Colors.black,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow, // Jaune vif pour rappeler Pac-Man
        padding: EdgeInsets.zero, // Pas de padding excessif pour éviter le décalage
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100), // Forme arrondie Pac-Man
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(100),
            bottomRight: Radius.circular(100),
          ),
        ),
        side: BorderSide(
          color: Colors.black, // Bordure noire rétro
          width: 3, // Bordure épaisse pour effet rétro
        ),
        fixedSize: Size(buttonWidth, buttonHeight), // Taille du bouton relative à l'écran
      ),
    );
  }
}

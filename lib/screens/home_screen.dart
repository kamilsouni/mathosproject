import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/sign_in_up_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _buttonPressed = false; // Pour gérer l'état du bouton lors du clic
  bool _isAnimationInitialized = false; // Nouveau flag pour s'assurer de l'initialisation

  @override
  void initState() {
    super.initState();
    _fadeIn();

    // Initialiser l'animation pour faire clignoter le bouton
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimation();
    });

    _checkCurrentUser();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1), // Durée du cycle de clignotement
      vsync: this,
    )..repeat(reverse: true); // Répéter l'animation

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_animationController);

    setState(() {
      _isAnimationInitialized = true; // Marquer comme initialisé
    });
  }

  void _fadeIn() {
    Future.delayed(Duration(milliseconds: 150), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  void _checkCurrentUser() async {
    auth.User? user = auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('profiles').doc(user.uid).get();
      AppUser appUser;

      if (userProfile.exists) {
        appUser = AppUser.fromJson(userProfile.data() as Map<String, dynamic>);
      } else {
        appUser = AppUser(
          id: user.uid,
          name: 'Nouvel Utilisateur',
          email: user.email ?? '',
          age: 0,
          gender: '',
          flag: 'assets/france.png',
          progression: AppUser.initializeProgression(),
        );
        await FirebaseFirestore.instance.collection('profiles').doc(user.uid).set(appUser.toJson());
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: appUser)),
      );
    }
  }

  void _onButtonPressed() {
    setState(() {
      _buttonPressed = true; // Le bouton est pressé et brille
    });

    // Revenir à l'état initial après un court délai (signal lumineux)
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _buttonPressed = false; // Fin de la brillance
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInUpScreen()),
      );
    });
  }

  @override
  void dispose() {
    if (_isAnimationInitialized) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xFF564560), // Couleur de fond pour un effet rétro
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logov2.png', // Chemin vers le logo en style pixel art
                    width: screenWidth * 0.9,
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  SizedBox(height: screenHeight * 0.15),

                  // Bouton style Pac-Man avec clignotement et brillance au clic
                  _isAnimationInitialized
                      ? AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _animation.value, // Appliquer l'effet de clignotement
                        child: ElevatedButton(
                          onPressed: _onButtonPressed, // Appel à la fonction lors du clic
                          child: Text(
                            'Commencer',
                            style: TextStyle(
                              fontFamily: 'PixelFont', // Utiliser une police pixel art
                              fontSize: screenWidth * 0.06, // Taille adaptée au style rétro
                              color: Colors.black, // Contraste avec le jaune
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonPressed
                                ? Colors.yellowAccent // Effet lumineux (jaune) lorsqu'on clique
                                : Colors.yellow, // Couleur de Pac-Man (jaune vif)
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.12,
                              vertical: screenHeight * 0.03,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(100), // Forme Pac-Man
                                topRight: Radius.circular(0), // Pas de bordure arrondie ici
                                bottomLeft: Radius.circular(100), // Forme Pac-Man
                                bottomRight: Radius.circular(100),
                              ),
                            ),
                            side: BorderSide(
                              color: Colors.black, // Bordure noire rétro
                              width: 3, // Bordure épaisse pour un effet rétro
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : ElevatedButton(
                    onPressed: _onButtonPressed, // Appel à la fonction lors du clic
                    child: Text(
                      'Commencer',
                      style: TextStyle(
                        fontFamily: 'PixelFont', // Utiliser une police pixel art
                        fontSize: screenWidth * 0.06, // Taille adaptée au style rétro
                        color: Colors.black, // Contraste avec le jaune
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonPressed
                          ? Colors.yellowAccent // Effet lumineux (jaune) lorsqu'on clique
                          : Colors.yellow, // Couleur de Pac-Man (jaune vif)
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.12,
                        vertical: screenHeight * 0.03,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100), // Forme Pac-Man
                          topRight: Radius.circular(0), // Pas de bordure arrondie ici
                          bottomLeft: Radius.circular(100), // Forme Pac-Man
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      side: BorderSide(
                        color: Colors.black, // Bordure noire rétro
                        width: 3, // Bordure épaisse pour un effet rétro
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

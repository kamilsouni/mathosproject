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

class _HomeScreenState extends State<HomeScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeIn();
    _checkCurrentUser();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
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
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png', // Remplacez par le chemin de votre logo
                    width: screenWidth * 0.8,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Progressez en jouant, calculez en vous amusant.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.1),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInUpScreen()),
                      );
                    },
                    child: Text(
                      'Commencer',
                      style: TextStyle(
                          fontSize: screenWidth * 0.08, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.7),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.15,
                          vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
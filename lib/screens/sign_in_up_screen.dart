import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/profile_creation_screen.dart';
import 'package:mathosproject/widgets/PacManButton.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';

class SignInUpScreen extends StatefulWidget {
  @override
  _SignInUpScreenState createState() => _SignInUpScreenState();
}

class _SignInUpScreenState extends State<SignInUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  auth.User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    _currentUser = auth.FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'PixelFont')),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Vérification locale avant de lancer la requête
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Veuillez entrer votre e-mail et mot de passe.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('profiles').doc(userCredential.user!.uid).get();
      if (!userProfile.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileCreationScreen(
            userId: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
          )),
        );
        return;
      }

      AppUser appUser = AppUser.fromJson(userProfile.data() as Map<String, dynamic>);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: appUser)),
      );
    } on auth.FirebaseAuthException catch (e) {
      String message = 'Une erreur s\'est produite.';
      if (e.code == 'user-not-found') {
        message = 'Utilisateur non trouvé. Veuillez vérifier vos informations de connexion.';
      } else if (e.code == 'wrong-password') {
        message = 'Mot de passe incorrect. Veuillez réessayer.';
      } else if (e.code == 'invalid-email') {
        message = 'L\'email est invalide. Veuillez vérifier votre adresse e-mail.';
      } else {
        message = e.message ?? 'Une erreur s\'est produite.';
      }

      _showErrorSnackBar(message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Veuillez entrer votre e-mail et mot de passe.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileCreationScreen(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
        )),
      );
    } on auth.FirebaseAuthException catch (e) {
      String message = 'Une erreur s\'est produite.';
      if (e.code == 'email-already-in-use') {
        message = 'Cet e-mail est déjà utilisé.';
      } else if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible. Choisissez un mot de passe plus sécurisé.';
      } else if (e.code == 'invalid-email') {
        message = 'L\'email est invalide. Veuillez vérifier votre adresse e-mail.';
      } else {
        message = e.message ?? 'Une erreur s\'est produite.';
      }

      _showErrorSnackBar(message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Force the user to choose an account
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(credential);

      DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('profiles').doc(userCredential.user!.uid).get();
      if (!userProfile.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileCreationScreen(
            userId: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
          )),
        );
        return;
      }

      AppUser appUser = AppUser.fromJson(userProfile.data() as Map<String, dynamic>);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: appUser)),
      );
    } on auth.FirebaseAuthException catch (e) {
      _showErrorSnackBar('Une erreur s\'est produite. ${e.message}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await auth.FirebaseAuth.instance.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Force sign out from Google account
    _checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double cmToPixels = 0.393701 * 160; // Conversion approximative de cm en pixels pour un écran de densité moyenne (160 dpi)
    double verticalPadding = cmToPixels * 1; // 1 cm en pixels

    return Scaffold(
      appBar: TopAppBar(title: 'Inscription / Connexion', showBackButton: true), // Ajouter la flèche de retour
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xFF564560), // Couleur de fond pour un effet rétro
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1).copyWith(top: verticalPadding),
            child: Column(
              children: [
                SizedBox(height: verticalPadding * 0.2), // 0.5 cm de marge supplémentaire
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(fontFamily: 'PixelFont'),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            labelStyle: TextStyle(fontFamily: 'PixelFont'),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: screenHeight * 0.07),
                        if (_isLoading)
                          CircularProgressIndicator()
                        else
                          Column(
                            children: [
                              PacManButton(
                                text: 'Connexion',
                                onPressed: _signInWithEmail,
                                isLoading: _isLoading,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              PacManButton(
                                text: 'Inscription',
                                onPressed: _signUp,
                                isLoading: _isLoading,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              PacManButton(
                                text: 'Connexion avec Google',
                                onPressed: _signInWithGoogle,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';
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
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUpMode = false;
  auth.User? _currentUser;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.yellow,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _checkCurrentUser();
    _setPersistence();
  }

  Future<void> _setPersistence() async {
    await auth.FirebaseAuth.instance.setPersistence(auth.Persistence.LOCAL);
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

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('Veuillez entrer votre e-mail pour réinitialiser le mot de passe.');
      return;
    }

    try {
      await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showErrorSnackBar('Un lien de réinitialisation a été envoyé à votre adresse e-mail.');
    } on auth.FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? 'Une erreur s\'est produite.');
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar('Veuillez remplir tous les champs.');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar('Les mots de passe ne correspondent pas.');
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

  Future<void> _signInWithEmail() async {
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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Force the user to choose an account
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double cmToPixels = 0.393701 * 160;
    double verticalPadding = cmToPixels * 1;

    return Scaffold(
      appBar: TopAppBar(title: 'Inscription / Connexion', showBackButton: true),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(0xFF564560),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1).copyWith(top: verticalPadding),
            child: Column(
              children: [
                SizedBox(height: verticalPadding * 0.2),
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
                        if (_isSignUpMode)
                          SizedBox(height: screenHeight * 0.05),
                        if (_isSignUpMode)
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirmez le mot de passe',
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
                                onPressed: () {
                                  setState(() {
                                    _isSignUpMode = false;
                                  });
                                  _signInWithEmail();
                                },
                                isLoading: _isLoading,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              PacManButton(
                                text: 'Inscription',
                                onPressed: () {
                                  setState(() {
                                    _isSignUpMode = true;
                                  });
                                  _signUp();
                                },
                                isLoading: _isLoading,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              PacManButton(
                                text: 'Connexion avec Google',
                                onPressed: _signInWithGoogle,
                                isLoading: _isLoading,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: TextButton(
                                      onPressed: _resetPassword,
                                      child: Text(
                                        'Mot de passe oublié?',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'PixelFont',
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/utils/connectivity_manager.dart'; // Import pour la gestion de la connectivité

class ProfileCreationScreen extends StatefulWidget {
  final String userId;
  final String email;

  ProfileCreationScreen({required this.userId, required this.email});

  @override
  _ProfileCreationScreenState createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  late String _name;
  late int _age;
  String _gender = '';
  String _selectedFlag = 'assets/france.png';
  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: TopAppBar(title: 'Créer un Profil'),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: SvgPicture.asset(
                  'assets/fond_d_ecran.svg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.only(top: 20), // Ajustez cette valeur si nécessaire
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Nom',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          focusNode: _nameFocusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          ),
                          textAlign: TextAlign.center,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un nom';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _name = value!;
                          },
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.06,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Âge',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          focusNode: _ageFocusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un âge';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _age = int.parse(value!);
                          },
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.06,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Genre',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        ToggleButtons(
                          borderColor: Colors.grey,
                          fillColor: Theme.of(context).colorScheme.secondary,
                          selectedBorderColor: Theme.of(context).primaryColor,
                          selectedColor: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Homme', style: TextStyle(fontSize: 18)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Femme', style: TextStyle(fontSize: 18)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Autre', style: TextStyle(fontSize: 18)),
                            ),
                          ],
                          onPressed: (int index) {
                            FocusScope.of(context).unfocus(); // Cacher le clavier
                            setState(() {
                              _gender = index == 0 ? 'Homme' : index == 1 ? 'Femme' : 'Autre';
                            });
                          },
                          isSelected: [_gender == 'Homme', _gender == 'Femme', _gender == 'Autre'],
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Text(
                          'Sélectionnez votre avatar',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.06,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFlagOption('assets/france.png'),
                            _buildFlagOption('assets/pirate.png'),
                            _buildFlagOption('assets/maroc.png'),
                            _buildFlagOption('assets/lgbt.png'),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _saveProfile();
                            }
                          },
                          child: Text(
                            'Valider',
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(screenWidth * 0.6, screenHeight * 0.05),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.1,
                              vertical: screenHeight * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagOption(String flagPath) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Cacher le clavier
        setState(() {
          _selectedFlag = flagPath;
        });
      },
      child: Opacity(
        opacity: _selectedFlag == flagPath ? 1.0 : 0.5,
        child: Image.asset(
          flagPath,
          width: 50,
          height: 50,
        ),
      ),
    );
  }

  void _saveProfile() async {
    Map<int, Map<String, Map<String, int>>> initialProgression = AppUser.initializeProgression();

    AppUser newUser = AppUser(
      id: widget.userId,
      name: _name,
      email: widget.email,
      age: _age,
      gender: _gender,
      flag: _selectedFlag,
      progression: initialProgression,
    );

    if (await ConnectivityManager().isConnected()) {
      await UserPreferences.saveProfileToFirestore(newUser);
    } else {
      await UserPreferences.saveProfile(newUser); // Enregistre localement et synchronise lorsque la connexion est disponible
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: newUser)),
    );
  }
}

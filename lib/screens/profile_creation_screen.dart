import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/widgets/PacManButton.dart';

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
    return Scaffold(
      appBar: TopAppBar(title: 'Créer un Profil'),
      body: Container(
        color: Color(0xFF564560),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildInputField('Nom', _nameFocusNode, (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un nom';
                              }
                              return null;
                            }, (value) {
                              _name = value!;
                            }),
                            _buildInputField('Âge', _ageFocusNode, (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un âge';
                              }
                              return null;
                            }, (value) {
                              _age = int.parse(value!);
                            }, keyboardType: TextInputType.number),
                            _buildGenderSelection(),
                            _buildFlagSelection(),
                            PacManButton(
                              text: 'Valider',
                              onPressed: _saveProfile,
                              isLoading: false,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInputField(String label, FocusNode focusNode, String? Function(String?) validator, void Function(String?) onSaved, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'PixelFont',
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          focusNode: focusNode,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'PixelFont',
          ),
          textAlign: TextAlign.center,
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genre',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'PixelFont',
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ToggleButtons(
            borderColor: Colors.transparent,
            fillColor: Colors.yellow,
            borderWidth: 2,
            selectedBorderColor: Colors.black,
            selectedColor: Colors.black,
            borderRadius: BorderRadius.circular(10),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Homme', style: TextStyle(fontSize: 16, fontFamily: 'PixelFont')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Femme', style: TextStyle(fontSize: 16, fontFamily: 'PixelFont')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Autre', style: TextStyle(fontSize: 16, fontFamily: 'PixelFont')),
              ),
            ],
            onPressed: (int index) {
              setState(() {
                _gender = index == 0 ? 'Homme' : index == 1 ? 'Femme' : 'Autre';
              });
            },
            isSelected: [_gender == 'Homme', _gender == 'Femme', _gender == 'Autre'],
          ),
        ),
      ],
    );
  }

  Widget _buildFlagSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélectionnez votre avatar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'PixelFont',
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFlagOption('assets/france.png'),
            _buildFlagOption('assets/pirate.png'),
            _buildFlagOption('assets/maroc.png'),
            _buildFlagOption('assets/lgbt.png'),
          ],
        ),
      ],
    );
  }

  Widget _buildFlagOption(String flagPath) {
    bool isSelected = _selectedFlag == flagPath;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFlag = flagPath;
        });
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(
          flagPath,
          width: 50,
          height: 50,
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

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
        await UserPreferences.saveProfile(newUser);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: newUser)),
      );
    }
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour charger le fichier JSON
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/widgets/PacManButton.dart';
import 'package:country_flags/country_flags.dart'; // Importation du package des drapeaux

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
  String _selectedFlag = 'FR'; // Code ISO initial pour le drapeau
  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();

  TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _flags = []; // Liste des drapeaux à partir du JSON
  List<Map<String, String>> _filteredFlags = []; // Liste filtrée pour la recherche

  @override
  void initState() {
    super.initState();
    _loadFlags(); // Charger les drapeaux lors de l'initialisation
    _searchController.addListener(_filterFlags); // Ajouter un listener pour la recherche
  }

  Future<void> _loadFlags() async {
    String jsonString = await rootBundle.loadString('assets/flags.json');
    List<dynamic> jsonResponse = json.decode(jsonString);

    setState(() {
      _flags = jsonResponse.map((flag) => {
        'name': flag['name'].toString(),
        'code': flag['code'].toString(),
      }).toList();

      _filteredFlags = _flags; // Initialise la liste filtrée avec tous les drapeaux
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    _searchController.dispose(); // Libérer le contrôleur de recherche
    super.dispose();
  }

  void _filterFlags() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFlags = _flags.where((flag) {
        String name = flag['name']!.toLowerCase();
        String code = flag['code']!.toLowerCase();
        return name.contains(query) || code.contains(query); // Filtrer par nom ou code
      }).toList();
    });
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
          'Sélectionnez votre drapeau',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'PixelFont',
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Rechercher un drapeau',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
        ),
        SizedBox(height: 16),
        _buildFlagList(),
      ],
    );
  }

  Widget _buildFlagList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _filteredFlags.map((flag) => _buildFlagOption(flag['code']!, flag['name']!)).toList(),
      ),
    );
  }

  Widget _buildFlagOption(String countryCode, String countryName) {
    bool isSelected = _selectedFlag == countryCode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFlag = countryCode;
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
        child: Column(
          children: [
            CountryFlag.fromCountryCode(
              countryCode,
              height: 50,
              width: 50,
            ),
            SizedBox(height: 4),
            Text(
              countryName,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
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
        flag: _selectedFlag, // Sauvegarde du code ISO du drapeau
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

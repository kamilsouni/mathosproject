import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';

class CreateCompetitionScreen extends StatefulWidget {
  final AppUser profile;

  CreateCompetitionScreen({required this.profile});

  @override
  _CreateCompetitionScreenState createState() => _CreateCompetitionScreenState();
}

class _CreateCompetitionScreenState extends State<CreateCompetitionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _competitionName = '';
  int _numRapidTests = 0;
  int _numPrecisionTests = 0;

  void _createCompetition() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (await ConnectivityManager().isConnected()) {
          // En ligne : créer la compétition dans Firestore
          DocumentReference competitionRef = await FirebaseFirestore.instance.collection('competitions').add({
            'name': _competitionName,
            'numRapidTests': _numRapidTests,
            'numPrecisionTests': _numPrecisionTests,
            'createdBy': widget.profile.id,
          });

          // Ajouter le créateur en tant que participant
          await competitionRef.collection('participants').doc(widget.profile.id).set({
            'name': widget.profile.name,
            'rapidTests': 0,
            'precisionTests': 0,
            'totalPoints': 0,
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CompetitionScreen(
                profile: widget.profile,
                competitionId: competitionRef.id,
              ),
            ),
          );
        } else {
          // Hors ligne : stocker localement
          String tempId = DateTime.now().millisecondsSinceEpoch.toString();
          await HiveDataManager.saveData('competitions', tempId, {
            'name': _competitionName,
            'numRapidTests': _numRapidTests,
            'numPrecisionTests': _numPrecisionTests,
            'createdBy': widget.profile.id,
            'participants': {
              widget.profile.id: {
                'name': widget.profile.name,
                'rapidTests': 0,
                'precisionTests': 0,
                'totalPoints': 0,
              }
            },
          });

          // Naviguer vers l'écran de compétition avec l'ID temporaire
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CompetitionScreen(
                profile: widget.profile,
                competitionId: tempId,
              ),
            ),
          );
        }
      } catch (e) {
        print('Error creating competition: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une compétition'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.7,
              child: SvgPicture.asset(
                'assets/fond_d_ecran.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nom de la compétition',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _competitionName = value!;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombre de tests de rapidité',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nombre';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _numRapidTests = int.parse(value!);
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombre de tests de précision',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nombre';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _numPrecisionTests = int.parse(value!);
                      },
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createCompetition,
                        child: Text('Créer la compétition'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.7),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

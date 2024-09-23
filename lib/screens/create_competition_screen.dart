import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:mathosproject/widgets/PacManButton.dart';

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
  int _numProblemTests = 0;
  int _numEquationTests = 0;
  bool _isLoading = false;

  void _createCompetition() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (await ConnectivityManager().isConnected()) {
          DocumentReference competitionRef = await FirebaseFirestore.instance.collection('competitions').add({
            'name': _competitionName,
            'numRapidTests': _numRapidTests,
            'numProblemTests': _numProblemTests,
            'numEquationTests': _numEquationTests,
            'createdBy': widget.profile.id,
          });

          await competitionRef.collection('participants').doc(widget.profile.id).set({
            'name': widget.profile.name,
            'rapidTests': 0,
            'ProblemTests': 0,
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
          String tempId = DateTime.now().millisecondsSinceEpoch.toString();
          await HiveDataManager.saveData('competitions', tempId, {
            'name': _competitionName,
            'numRapidTests': _numRapidTests,
            'numProblemTests': _numProblemTests,
            'numEquationTests': _numEquationTests,
            'createdBy': widget.profile.id,
            'participants': {
              widget.profile.id: {
                'name': widget.profile.name,
                'rapidTests': 0,
                'ProblemTests': 0,
                'equationTests': 0,
                'totalPoints': 0,
              }
            },
          });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création de la compétition: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildInputField(String label, String hint, void Function(String?) onSaved, String? Function(String?) validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.yellow, fontFamily: 'PixelFont', fontSize: 14),
        ),
        SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border.all(color: Colors.yellow, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'PixelFont', fontSize: 12),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            validator: validator,
            onSaved: onSaved,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Créer une compétition',
        showBackButton: true,
      ),
      body: Container(
        color: Color(0xFF564560), // Fond violet
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1, // Réduit de 2 à 1
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end, // Changé à end
                    children: [
                      Text(
                        'Définissez les paramètres ci-dessous:',
                        style: TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 14), // Taille réduite à 14
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 0), // Ajout d'un petit espace
                    ],
                  ),
                ),
                Expanded(
                  flex: 8, // Augmenté de 7 à 8
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInputField(
                          'Nom de la compétition',
                          'Entrez un nom accrocheur',
                              (value) => _competitionName = value!,
                              (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
                        ),
                        _buildInputField(
                          'Nombre de tests de rapidité',
                          'Ex: 5',
                              (value) => _numRapidTests = int.parse(value!),
                              (value) => value!.isEmpty || int.tryParse(value) == null ? 'Entrez un nombre valide' : null,
                        ),
                        _buildInputField(
                          'Nombre de tests de problème',
                          'Ex: 3',
                              (value) => _numProblemTests = int.parse(value!),
                              (value) => value!.isEmpty || int.tryParse(value) == null ? 'Entrez un nombre valide' : null,
                        ),
                        _buildInputField(
                          'Nombre de tests d\'équation',
                          'Ex: 4',
                              (value) => _numEquationTests = int.parse(value!),
                              (value) => value!.isEmpty || int.tryParse(value) == null ? 'Entrez un nombre valide' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: PacManButton(
                      text: 'Créer la compétition',
                      onPressed: _createCompetition,
                      isLoading: _isLoading,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
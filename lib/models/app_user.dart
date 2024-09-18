import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mathosproject/user_preferences.dart';
part 'app_user.g.dart';

@HiveType(typeId: 0)
class AppUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  String gender;

  @HiveField(4)
  String email;

  @HiveField(5)
  int points;

  @HiveField(6)
  String flag;

  @HiveField(7)
  Map<int, Map<String, Map<String, int>>> progression;

  @HiveField(8)
  int rapidTestRecord;

  @HiveField(9)
  int ProblemTestRecord;

  @HiveField(10)
  int equationTestRecord;

  AppUser({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
    this.points = 0,
    required this.flag,
    this.rapidTestRecord = 0,
    this.ProblemTestRecord = 0,
    this.equationTestRecord = 0,
    Map<int, Map<String, Map<String, int>>>? progression,
  }) : this.progression = progression ?? initializeProgression();

  // Initialisation de la progression par défaut
  static Map<int, Map<String, Map<String, int>>> initializeProgression() {
    Map<int, Map<String, Map<String, int>>> progression = {};
    for (int level = 1; level <= 10; level++) {
      progression[level] = {
        'Addition': {'accessibility': level == 1 ? 1 : 0, 'validation': 0},
        'Soustraction': {'accessibility': level == 1 ? 1 : 0, 'validation': 0},
        'Multiplication': {'accessibility': level == 1 ? 1 : 0, 'validation': 0},
        'Division': {'accessibility': level == 1 ? 1 : 0, 'validation': 0},
        'Mixte': {'accessibility': 0, 'validation': 0},
      };
    }
    return progression;
  }

  // Mise à jour de l'accessibilité des niveaux et des opérations
  void updateAccessibility() {
    for (int level = 1; level <= 10; level++) {
      bool allOperatorsValidated = true;
      for (String op in ['Addition', 'Soustraction', 'Multiplication', 'Division']) {
        if (progression[level]?[op]?['validation'] != 1) {
          allOperatorsValidated = false;
          break;
        }
      }
      if (allOperatorsValidated) {
        progression[level]!['Mixte']!['accessibility'] = 1;
      }
    }
  }

  // Validation des opérateurs pour un niveau donné
  bool validateOperator(int level, String operator) {
    if (progression[level]?[operator]?['accessibility'] == 1) {
      progression[level]?[operator]?['validation'] = 1;

      bool allOperatorsValidated = true;
      for (String op in ['Addition', 'Soustraction', 'Multiplication', 'Division']) {
        if (progression[level]?[op]?['validation'] != 1) {
          allOperatorsValidated = false;
          break;
        }
      }

      if (allOperatorsValidated) {
        progression[level]!['Mixte']!['accessibility'] = 1;
      }

      bool allValidated = true;
      for (String op in ['Addition', 'Soustraction', 'Multiplication', 'Division', 'Mixte']) {
        if (progression[level]?[op]?['validation'] != 1) {
          allValidated = false;
          break;
        }
      }

      if (allValidated && level < 10) {
        progression[level + 1]!['Addition']!['accessibility'] = 1;
        progression[level + 1]!['Soustraction']!['accessibility'] = 1;
        progression[level + 1]!['Multiplication']!['accessibility'] = 1;
        progression[level + 1]!['Division']!['accessibility'] = 1;
      }

      return allValidated;
    }
    return false;
  }




  void updateRecords({
    required int newRapidPoints,
    required int newProblemPoints,
    required int newEquationPoints
  }) async {
    if (newRapidPoints > rapidTestRecord) {
      rapidTestRecord = newRapidPoints;
    }
    if (newProblemPoints > ProblemTestRecord) {
      ProblemTestRecord = newProblemPoints;
    }
    if (newEquationPoints > equationTestRecord) {
      equationTestRecord = newEquationPoints;
    }

    // Synchroniser les records mis à jour avec Firebase
    if (await isOnline()) {
      await UserPreferences.updateProfileInFirestore(this); // Sync with Firebase
    } else {
      await saveToLocalStorage(); // Save locally if offline
    }
  }


  // Sauvegarde des données localement
  Future<void> saveToLocalStorage() async {
    var box = await Hive.openBox('userBox');
    await box.put('userData', this.toJson()); // Sauvegarder les données utilisateur
  }

  // Chargement des données utilisateur à partir du stockage local
  static Future<AppUser?> loadFromLocalStorage() async {
    var box = await Hive.openBox('userBox');
    var userData = box.get('userData');
    if (userData != null) {
      return AppUser.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  // Effacement des données locales après synchronisation
  Future<void> clearLocalStorage() async {
    var box = await Hive.openBox('userBox');
    await box.delete('userData');
  }

  Future<bool> isOnline() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity().timeout(Duration(seconds: 2));
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false; // Considérer comme hors ligne si un timeout ou une erreur survient
    }
  }

  // Synchronisation des données locales avec Firebase
  Future<void> syncWithFirebase() async {
    if (await isOnline()) {
      // Charger les données locales
      AppUser? localUser = await loadFromLocalStorage();
      if (localUser != null) {
        // Mettre à jour Firebase avec les données locales
        await UserPreferences.updateProfileInFirestore(localUser);

        // Effacer les données locales après synchronisation réussie
        await clearLocalStorage();
      }
    } else {
      // Si la synchronisation échoue, garder les données locales et réessayer plus tard
      print("Pas de connexion, synchronisation reportée.");
    }
  }


  // Conversion des données en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'email': email,
      'points': points,
      'flag': flag,
      'rapidTestRecord': rapidTestRecord,
      'ProblemTestRecord': ProblemTestRecord,
      'equationTestRecord': equationTestRecord,
      'progression': progression.map((key, value) => MapEntry(key.toString(), value.map((k, v) => MapEntry(k, v)))),
    };
  }

  // Création d'un utilisateur à partir d'un snapshot Firebase
  factory AppUser.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  // Création d'un utilisateur à partir d'un utilisateur Firebase
  static Future<AppUser> fromFirebaseUser(auth.User user,
      {required int age,
        required String name,
        required String gender,
        required String flag}) async {
    return AppUser(
      id: user.uid,
      name: name,
      email: user.email ?? '',
      age: age,
      gender: gender,
      flag: flag,
      progression: initializeProgression(),
      points: 0,
    );
  }

  // Création d'un utilisateur à partir d'un JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      email: json['email'],
      points: json['points'] ?? 0,
      flag: json['flag'],
      rapidTestRecord: json['rapidTestRecord'] ?? 0,
      ProblemTestRecord: json['ProblemTestRecord'] ?? 0,
      equationTestRecord: json['equationTestRecord'] ?? 0,
      progression: json['progression'] != null
          ? (json['progression'] as Map).map((key, value) => MapEntry(
          int.parse(key),
          (value as Map).map((k, v) => MapEntry(k, Map<String, int>.from(v)))))
          : initializeProgression(),
    );
  }
}

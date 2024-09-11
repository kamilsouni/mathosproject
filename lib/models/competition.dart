import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'competition.g.dart';

@HiveType(typeId: 1)
class Competition extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String creatorId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int numRapidTests;

  @HiveField(4)
  final int numPrecisionTests;

  @HiveField(5)
  final Map<String, dynamic> participants; // {userId: participantData}

  Competition({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.numRapidTests,
    required this.numPrecisionTests,
    required this.participants,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'name': name,
      'numRapidTests': numRapidTests,
      'numPrecisionTests': numPrecisionTests,
      'participants': participants,
    };
  }

  static Competition fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Competition(
      id: data['id'],
      creatorId: data['creatorId'],
      name: data['name'],
      numRapidTests: data['numRapidTests'],
      numPrecisionTests: data['numPrecisionTests'],
      participants: data['participants'],
    );
  }

  // Sauvegarde des données localement
  Future<void> saveToLocalStorage() async {
    var box = await Hive.openBox('competitionBox');
    await box.put(id, this.toJson()); // Sauvegarder la compétition par ID
  }

  // Chargement des données à partir du stockage local
  static Future<Competition?> loadFromLocalStorage(String id) async {
    var box = await Hive.openBox('competitionBox');
    var competitionData = box.get(id);
    if (competitionData != null) {
      return Competition.fromJson(Map<String, dynamic>.from(competitionData));
    }
    return null;
  }

  // Effacement des données locales après synchronisation
  Future<void> clearLocalStorage() async {
    var box = await Hive.openBox('competitionBox');
    await box.delete(id);
  }

  // Vérification de la connectivité
  Future<bool> isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Synchronisation des données locales avec Firebase
  Future<void> syncWithFirebase() async {
    if (await isOnline()) {
      // Charger les données locales
      Competition? localCompetition = await loadFromLocalStorage(id);
      if (localCompetition != null) {
        // Mettre à jour Firebase avec les données locales
        await FirebaseFirestore.instance
            .collection('competitions')
            .doc(id)
            .set(localCompetition.toJson());
        // Effacer les données locales après synchronisation
        await clearLocalStorage();
      }
    }
  }

  // Factory method to create a Competition instance from JSON
  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'],
      creatorId: json['creatorId'],
      name: json['name'],
      numRapidTests: json['numRapidTests'],
      numPrecisionTests: json['numPrecisionTests'],
      participants: Map<String, dynamic>.from(json['participants']),
    );
  }
}

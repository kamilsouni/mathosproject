import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

part 'participant.g.dart';

@HiveType(typeId: 2)
class Participant extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int rapidTests;

  @HiveField(2)
  final int precisionTests;

  @HiveField(3)
  final int rapidPoints;

  @HiveField(4)
  final int precisionPoints;

  @HiveField(5)
  final int totalPoints;

  Participant({
    required this.name,
    required this.rapidTests,
    required this.precisionTests,
    required this.rapidPoints,
    required this.precisionPoints,
    required this.totalPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rapidTests': rapidTests,
      'precisionTests': precisionTests,
      'rapidPoints': rapidPoints,
      'precisionPoints': precisionPoints,
      'totalPoints': totalPoints,
    };
  }

  static Participant fromMap(Map<String, dynamic> data) {
    return Participant(
      name: data['name'],
      rapidTests: data['rapidTests'],
      precisionTests: data['precisionTests'],
      rapidPoints: data['rapidPoints'],
      precisionPoints: data['precisionPoints'],
      totalPoints: data['totalPoints'],
    );
  }

  // Sauvegarde des données localement
  Future<void> saveToLocalStorage(String participantId) async {
    var box = await Hive.openBox('participantBox');
    await box.put(participantId, this.toJson()); // Sauvegarder le participant par ID
  }

  // Chargement des données à partir du stockage local
  static Future<Participant?> loadFromLocalStorage(String participantId) async {
    var box = await Hive.openBox('participantBox');
    var participantData = box.get(participantId);
    if (participantData != null) {
      return Participant.fromMap(Map<String, dynamic>.from(participantData));
    }
    return null;
  }

  // Effacement des données locales après synchronisation
  Future<void> clearLocalStorage(String participantId) async {
    var box = await Hive.openBox('participantBox');
    await box.delete(participantId);
  }

  // Synchronisation des données locales avec Firebase
  Future<void> syncWithFirebase(String competitionId, String participantId) async {
    if (await isOnline()) {
      // Charger les données locales
      Participant? localParticipant = await loadFromLocalStorage(participantId);
      if (localParticipant != null) {
        // Mettre à jour Firebase avec les données locales
        await FirebaseFirestore.instance
            .collection('competitions')
            .doc(competitionId)
            .collection('participants')
            .doc(participantId)
            .set(localParticipant.toJson());
        // Effacer les données locales après synchronisation
        await clearLocalStorage(participantId);
      }
    }
  }

  // Vérification de la connectivité
  Future<bool> isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'dart:async';

class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;
  ConnectivityManager._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> subscription;

  // Méthode pour vérifier si une connexion réseau est disponible
  Future<bool> isConnected() async {
    var connectivityResult = await (_connectivity.checkConnectivity());
    return _isConnectedResult(connectivityResult);
  }
  Future<void> syncLocalDataWithFirebase(String competitionId) async {
    if (await isConnected()) {
      var localParticipantsData = await HiveDataManager.getAllData('competitionParticipants_$competitionId');

      for (var entry in localParticipantsData.entries) {
        await FirebaseFirestore.instance
            .collection('competitions')
            .doc(competitionId)
            .collection('participants')
            .doc(entry.key)
            .set(entry.value, SetOptions(merge: true));
      }

      print('Synced local data with Firebase for competition: $competitionId');
    }
  }

  // Méthode pour surveiller les changements de connexion réseau
  void monitorConnectivityChanges(Function(bool) onConnectivityChanged, [String? competitionId]) {
    subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool isConnected = results.any(_isConnectedSingleResult);
      onConnectivityChanged(isConnected);
      if (isConnected && competitionId != null) {
        syncLocalDataWithFirebase(competitionId);
      }
    });
  }

  bool _isConnectedResult(List<ConnectivityResult> results) {
    return results.any(_isConnectedSingleResult);
  }

  bool _isConnectedSingleResult(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  // Méthode pour synchroniser les données locales avec Firebase
  Future<void> syncDataWithFirebase() async {
    // Exemple : synchroniser les utilisateurs avec Firebase
    var localParticipants = await HiveDataManager.getAllData('competitionParticipants');
    for (var participantId in localParticipants.keys) {
      var participantData = localParticipants[participantId];
      FirebaseFirestore.instance
          .collection('competitions')
          .doc('your_competition_id') // Remplacer par ton ID de compétition
          .collection('participants')
          .doc(participantId)
          .set(participantData, SetOptions(merge: true));
    }
  }

  // Méthode pour forcer la synchronisation manuellement
  Future<void> syncNow(String competitionId) async {
    if (await isConnected()) {
      await syncDataWithFirebase();
    } else {
      print("Pas de connexion Internet disponible pour synchroniser les données.");
    }
  }

  // Dispose la subscription pour éviter les fuites de mémoire
  void dispose() {
    subscription.cancel();
  }
}
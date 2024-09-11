import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/utils/hive_data_manager.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';

class UserPreferences {
  static const String _tempDataBoxName = 'tempUserData';

  // Méthodes existantes pour Firestore
  static Future<void> saveProfileToFirestore(AppUser profile) async {
    try {
      await FirebaseFirestore.instance.collection('profiles').doc(profile.id).set(profile.toJson());
    } catch (e) {
      print('Error saving profile to Firestore: $e');
    }
  }

  static Future<AppUser?> getProfileFromFirestore(String id) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('profiles').doc(id).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting profile from Firestore: $e');
      return null;
    }
  }

  static Future<void> updateProfilePointsInFirestore(String id, int newPoints) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection('profiles').doc(id);
      await docRef.update({'points': newPoints});
    } catch (e) {
      print('Error updating profile points in Firestore: $e');
    }
  }

  static Future<void> deleteProfileFromFirestore(String id) async {
    try {
      await FirebaseFirestore.instance.collection('profiles').doc(id).delete();
    } catch (e) {
      print('Error deleting profile from Firestore: $e');
    }
  }

  static Future<void> updateProfileInFirestore(AppUser updatedProfile) async {
    try {
      await FirebaseFirestore.instance.collection('profiles').doc(updatedProfile.id).update(updatedProfile.toJson());
    } catch (e) {
      print('Error updating profile in Firestore: $e');
    }
  }

  static Future<void> clearAllProfilesInFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('profiles').get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
    } catch (e) {
      print('Error clearing all profiles in Firestore: $e');
    }
  }

  // Méthodes pour le mode hors ligne
  static Future<void> saveProfileLocally(AppUser profile) async {
    await HiveDataManager.saveData(_tempDataBoxName, profile.id, profile.toJson());
  }

  static Future<AppUser?> getProfileLocally(String id) async {
    final data = await HiveDataManager.getData(_tempDataBoxName, id);
    return data != null ? AppUser.fromJson(data) : null;
  }

  static Future<void> updateProfilePointsLocally(String id, int newPoints) async {
    AppUser? user = await getProfileLocally(id);
    if (user != null) {
      user.points = newPoints;
      await saveProfileLocally(user);
    }
  }

  static Future<void> deleteProfileLocally(String id) async {
    await HiveDataManager.deleteData(_tempDataBoxName, id);
  }

  // Méthodes combinées pour la gestion en ligne/hors ligne
  static Future<void> saveProfile(AppUser profile) async {
    await saveProfileLocally(profile);
    if (await ConnectivityManager().isConnected()) {
      await saveProfileToFirestore(profile);
      await deleteProfileLocally(profile.id);
    }
  }

  static Future<AppUser?> getProfile(String id) async {
    AppUser? localProfile = await getProfileLocally(id);
    if (localProfile != null) {
      return localProfile;
    }
    if (await ConnectivityManager().isConnected()) {
      return await getProfileFromFirestore(id);
    }
    return null;
  }

  static Future<void> updateProfilePoints(String id, int newPoints) async {
    await updateProfilePointsLocally(id, newPoints);
    if (await ConnectivityManager().isConnected()) {
      await updateProfilePointsInFirestore(id, newPoints);
      await deleteProfileLocally(id);
    }
  }

  static Future<void> deleteProfile(String id) async {
    await deleteProfileLocally(id);
    if (await ConnectivityManager().isConnected()) {
      await deleteProfileFromFirestore(id);
    }
  }

  static Future<void> updateProfile(AppUser updatedProfile) async {
    await saveProfileLocally(updatedProfile);
    if (await ConnectivityManager().isConnected()) {
      await updateProfileInFirestore(updatedProfile);
      await deleteProfileLocally(updatedProfile.id);
    }
  }

  static Future<void> syncProfiles() async {
    if (await ConnectivityManager().isConnected()) {
      final localProfiles = await HiveDataManager.getAllData(_tempDataBoxName);
      for (var entry in localProfiles.entries) {
        try {
          final profile = AppUser.fromJson(entry.value);
          await saveProfileToFirestore(profile);
          await deleteProfileLocally(profile.id);
        } catch (e) {
          print('Error syncing profile ${entry.key}: $e');
          // Optionnel : ajouter une logique pour réessayer plus tard
        }
      }
    }
  }

  // Méthode pour vérifier et synchroniser les données si nécessaire
  static Future<void> checkAndSyncData() async {
    if (await ConnectivityManager().isConnected()) {
      await syncProfiles();
    }
  }
}

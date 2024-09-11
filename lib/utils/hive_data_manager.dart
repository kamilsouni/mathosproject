import 'package:hive/hive.dart';

class HiveDataManager {
  // Cache pour stocker les boîtes ouvertes
  static final Map<String, Box> _openBoxes = {};

  // Méthode pour obtenir une boîte avec validation de type
  static Future<Box<T>> _getBox<T>(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      var box = _openBoxes[boxName];
      if (box is Box<T>) {
        return box;
      } else {
        // Si la boîte est déjà ouverte avec un mauvais type, on la ferme et on la rouvre avec le bon type
        await box!.close();
        _openBoxes.remove(boxName);
      }
    }

    final box = await Hive.openBox<T>(boxName);
    _openBoxes[boxName] = box;
    return box;
  }

  static Future<void> saveData<T>(String boxName, String key, T value) async {
    final box = await _getBox<T>(boxName);
    await box.put(key, value);
  }

  static Future<T?> getData<T>(String boxName, String key) async {
    final box = await _getBox(boxName);
    final data = box.get(key);

    if (data is Map && T == Map<String, dynamic>) {
      return Map<String, dynamic>.from(data as Map<dynamic, dynamic>) as T;
    }

    return data as T?;
  }

  static Future<void> deleteData(String boxName, String key) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  static Future<Map<dynamic, dynamic>> getAllData(String boxName) async {
    final box = await _getBox(boxName);
    return box.toMap();
  }

  static Future<void> clearBox(String boxName) async {
    final box = await _getBox(boxName);
    await box.clear();
  }

  // Méthode pour marquer les données en attente de synchronisation
  static Future<void> markDataForSync<T>(String boxName, String key, T value) async {
    final syncBox = await _getBox<Map>(boxName + '_sync');
    await syncBox.put(key, value as Map);
  }

  // Méthode pour obtenir toutes les données en attente de synchronisation
  static Future<Map<dynamic, dynamic>> getAllDataForSync(String boxName) async {
    final syncBox = await _getBox(boxName + '_sync');
    return syncBox.toMap();
  }

  // Méthode pour supprimer une seule entrée synchronisée après succès
  static Future<void> deleteSyncData(String boxName, String key) async {
    final syncBox = await _getBox(boxName + '_sync');
    await syncBox.delete(key);
  }
}

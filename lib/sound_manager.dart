import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  static late SharedPreferences _prefs;
  static bool _soundEnabled = true;
  static final AudioPlayer _buttonPlayer = AudioPlayer();
  static final AudioPlayer _dialogPlayer = AudioPlayer();
  static final AudioPlayer _yesPlayer = AudioPlayer();
  static final AudioPlayer _noPlayer = AudioPlayer();
  static bool _vibrationEnabled = true;  // Nouvelle variable pour le vibreur

  static Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _soundEnabled = _prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = _prefs.getBool('vibrationEnabled') ?? true;  // Initialisation du vibreur

      await preLoadAllSounds();
    } catch (e) {
      print('Erreur lors de l\'initialisation du SoundManager: $e');
      _soundEnabled = true;
      _vibrationEnabled = true;

    }
  }

  // Nouvelles méthodes pour le vibreur
  static void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    _prefs.setBool('vibrationEnabled', enabled);
  }

  static bool isVibrationEnabled() {
    return _vibrationEnabled;
  }



  static Future<void> preLoadAllSounds() async {
    await Future.wait([
      _buttonPlayer.setSource(AssetSource('sounds/button.mp3')),
      _dialogPlayer.setSource(AssetSource('sounds/dialog_open.mp3')),
      _yesPlayer.setSource(AssetSource('sounds/yes_button.mp3')),
      _noPlayer.setSource(AssetSource('sounds/no_button.mp3')),
    ]);
  }

  static Future<void> playButtonClickSound() async {
    if (_soundEnabled) {
      await _buttonPlayer.play(AssetSource('sounds/button.mp3'));
    }
  }

  static Future<void> playDialogOpenSound() async {
    if (_soundEnabled) {
      await _dialogPlayer.play(AssetSource('sounds/dialog_open.mp3'));
    }
  }

  static Future<void> playYesButtonSound() async {
    if (_soundEnabled) {
      await _yesPlayer.play(AssetSource('sounds/yes_button.mp3'));
    }
  }

  static Future<void> playNoButtonSound() async {
    if (_soundEnabled) {
      await _noPlayer.play(AssetSource('sounds/no_button.mp3'));
    }
  }

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _prefs.setBool('soundEnabled', enabled);
  }

  static bool isSoundEnabled() {
    return _soundEnabled;
  }
}
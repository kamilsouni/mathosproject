import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static AudioPlayer _audioPlayer = AudioPlayer();

  // Précharge tous les sons au lancement de l'application
  static Future<void> preLoadAllSounds() async {
    await _audioPlayer.setSource(AssetSource('sounds/button.mp3')); // Précharge les sons ici
    // Ajoute ici d'autres sons à précharger
    //await _audioPlayer.setSource(AssetSource('sounds/another_sound.mp3'));
    //await _audioPlayer.setSource(AssetSource('sounds/success.mp3'));
  }

  // Méthode pour jouer un son spécifique
  static Future<void> playButtonClickSound() async {
    await _audioPlayer.play(AssetSource('sounds/button.mp3')); // Joue le son
  }

  // Méthode pour jouer le son lors de l'ouverture d'un dialogue
  static Future<void> playDialogOpenSound() async {
    await _audioPlayer.play(AssetSource('sounds/button.mp3')); // Remplace par ton fichier
  }

  // Méthode pour jouer le son du bouton "Yes" d'un dialogue
  static Future<void> playYesButtonSound() async {
    await _audioPlayer.play(AssetSource('sounds/button.mp3')); // Remplace par ton fichier
  }

  // Méthode pour jouer le son du bouton "No" d'un dialogue
  static Future<void> playNoButtonSound() async {
    await _audioPlayer.play(AssetSource('sounds/button.mp3')); // Remplace par ton fichier
  }
}

/// Audio manager placeholder for Spider-Man 2D.
/// Ready for integration with audioplayers package.
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  void toggleSound() => _soundEnabled = !_soundEnabled;

  void playShoot() { /* TODO: web shoot sfx */ }
  void playShotgun() { /* TODO: web burst sfx */ }
  void playPlasma() { /* TODO: impact web sfx */ }
  void playEnemyHit() { /* TODO: enemy hit sfx */ }
  void playEnemyDeath() { /* TODO: enemy death sfx */ }
  void playPlayerHurt() { /* TODO: player hurt sfx */ }
  void playPickup() { /* TODO: pickup sfx */ }
  void playDoorOpen() { /* TODO: door open sfx */ }
  void playLevelComplete() { /* TODO: level complete sfx */ }
  void playGameOver() { /* TODO: game over sfx */ }
  void playMenuMusic() { /* TODO: menu music */ }
  void playGameMusic() { /* TODO: game music */ }
  void stopMusic() { /* TODO: stop music */ }
  void dispose() { stopMusic(); }
}

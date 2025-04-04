import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> initializeSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      // print('Error initializing audio session: $e');
    }
  }

  Future<void> setPlaylist(List<dynamic> audios, String baseUrl) async {
    final playlist = ConcatenatingAudioSource(
      children: audios
          .map((audio) => AudioSource.uri(
                Uri.parse("$baseUrl/${audio['url']}"),
                tag: audio['episode'],
              ))
          .toList(),
    );

    await _player.setAudioSource(playlist);
  }

  Future<void> togglePlay() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e) {
      // print('Error toggling playback: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  void dispose() {
    _player.dispose();
  }
}

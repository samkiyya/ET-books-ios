import 'package:book_mobile/constants/logger.dart';
import 'package:book_mobile/services/audio_handler_service.dart';
import 'package:just_audio/just_audio.dart';
import 'platform_checker.dart';

class AudioPlayerService {
  final AudioPlayer _player;
  final AudioHandler _audioHandler;
  bool _isReady = false;

  AudioPlayerService()
      : _player = AudioPlayer(
          androidApplyAudioAttributes: PlatformChecker.isAndroid,
          handleInterruptions: true,
        ),
        _audioHandler = AudioHandler();

  AudioPlayer get player => _player;
  bool get isReady => _isReady;

  Future<bool> initialize() async {
    try {
      final success = await _audioHandler.initializeAudioSession();
      if (!success) {
        Logger.error('Failed to initialize audio session');
        return false;
      }

      // Set up error handling
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _audioHandler.abandonAudioFocus();
        }
      }, onError: (error) {
        Logger.error('Player state error', error);
      });

      _isReady = true;
      return true;
    } catch (e) {
      Logger.error('Error initializing audio player', e);
      return false;
    }
  }

  Future<void> setPlaylist(List<dynamic> audios, String baseUrl) async {
    if (!_isReady) {
      Logger.error('Audio player not initialized');
      return;
    }

    try {
      final playlist = ConcatenatingAudioSource(
        children: audios
            .map((audio) => AudioSource.uri(
                  Uri.parse("$baseUrl/${audio['url']}"),
                  tag: audio['episode'],
                ))
            .toList(),
      );

      await _player.setAudioSource(playlist, initialPosition: Duration.zero);
    } catch (e) {
      Logger.error('Error setting playlist', e);
    }
  }

  Future<void> togglePlay() async {
    if (!_isReady) return;

    try {
      if (_player.playing) {
        await _player.pause();
        await _audioHandler.abandonAudioFocus();
      } else {
        await _audioHandler.requestAudioFocus();
        await _player.play();
      }
    } catch (e) {
      Logger.error('Error toggling playback', e);
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isReady) return;

    try {
      await _player.setVolume(volume);
    } catch (e) {
      Logger.error('Error setting volume', e);
    }
  }

  void dispose() {
    try {
      _player.stop();
      _player.dispose();
      _audioHandler.abandonAudioFocus();
    } catch (e) {
      Logger.error('Error disposing audio player', e);
    }
  }
}

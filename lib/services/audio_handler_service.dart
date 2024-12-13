import 'package:book_mobile/constants/logger.dart';
import 'package:audio_session/audio_session.dart';
import 'platform_checker.dart';

class AudioHandler {
  static final AudioHandler _instance = AudioHandler._internal();
  bool _isInitialized = false;

  factory AudioHandler() {
    return _instance;
  }

  AudioHandler._internal();

  Future<bool> initializeAudioSession() async {
    if (_isInitialized) return true;
    if (!PlatformChecker.supportsNativeAudio) {
      Logger.info(
          'Platform does not support native audio - using web fallback');
      _isInitialized = true;
      return true;
    }

    try {
      final session = await AudioSession.instance;
      const configuration = AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      );

      await session.configure(configuration);
      _isInitialized = true;
      return true;
    } catch (e) {
      Logger.error('Failed to initialize audio session', e);
      // Fallback to basic initialization
      _isInitialized = true;
      return true;
    }
  }

  Future<void> requestAudioFocus() async {
    if (!PlatformChecker.supportsNativeAudio) return;

    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
    } catch (e) {
      Logger.error('Failed to request audio focus', e);
    }
  }

  Future<void> abandonAudioFocus() async {
    if (!PlatformChecker.supportsNativeAudio) return;

    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (e) {
      Logger.error('Failed to abandon audio focus', e);
    }
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';

class EpisodeService {
  static final _dio = Dio();
  static final _audioPlayer = AudioPlayer();
  static bool isPlaying = false; // Track the playback state

  static Future<String> getEpisodePath(int bookId, int episodeId) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/book_${bookId}_episode_${episodeId}.mp3';
  }

  static Future<bool> isEpisodeDownloaded(int bookId, int episodeId) async {
    final path = await getEpisodePath(bookId, episodeId);
    return File(path).existsSync();
  }

  static Future<void> playEpisode(int bookId, int episodeId) async {
    final path = await getEpisodePath(bookId, episodeId);
    if (await File(path).exists()) {
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
    }
  }

  static Future<void> togglePlayPause(int bookId, int episodeId) async {
    final path = await getEpisodePath(bookId, episodeId);

    if (await File(path).exists()) {
      if (isPlaying) {
        // Pause the audio if it's already playing
        await _audioPlayer.pause();
      } else {
        // Otherwise play the episode
        await _audioPlayer.setFilePath(path);
        await _audioPlayer.play();
      }
      isPlaying = !isPlaying; // Toggle the playback state
    }
  }

  static Future<void> downloadEpisode({
    required int bookId,
    required int episodeId,
    required String url,
    required Function(double) onProgress,
  }) async {
    final path = await getEpisodePath(bookId, episodeId);
    try {
      await _dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );
    } catch (e) {
      print('Error downloading episode: $e');
    }
  }
}

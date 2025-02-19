import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:bookreader/services/episode_service.dart';

class AudioEpisodeScreen extends StatefulWidget {
  final Map<String, dynamic> audioBook;

  const AudioEpisodeScreen({super.key, required this.audioBook});

  @override
  State<AudioEpisodeScreen> createState() => _AudioEpisodeScreenState();
}

class _AudioEpisodeScreenState extends State<AudioEpisodeScreen> {
  final Map<int, double> _downloadProgress = {};
  final Set<int> _downloadingIds = {};
  final Map<int, bool> _isPlaying = {}; // Track play state for each episode

  @override
  Widget build(BuildContext context) {
    final episodes = widget.audioBook['audios'] as List<dynamic>?;

    if (episodes == null || episodes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Audio Episodes',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.color6,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color2,
        ),
        body: const Center(
          child: Text("The book has no episodes currently.",
              style: AppTextStyles.bodyText),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.audioBook['title'],
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.color6,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color2,
      ),
      body: ListView.builder(
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          final episode = episodes[index];
          final episodeId = episode['id'];

          return ListTile(
            leading: const Icon(Icons.music_note, color: AppColors.color3),
            title: Text(episode['episode'], style: AppTextStyles.bodyText),
            trailing: _downloadingIds.contains(episodeId)
                ? SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _downloadProgress[episodeId],
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.color3),
                        ),
                        Text(
                          "${(_downloadProgress[episodeId]! * 100).toInt()}%",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.color3,
                          ),
                        ),
                      ],
                    ),
                  )
                : FutureBuilder<bool>(
                    future: EpisodeService.isEpisodeDownloaded(
                        widget.audioBook['id'], episodeId),
                    builder: (context, snapshot) {
                      final isDownloaded = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isDownloaded
                              ? (_isPlaying[episodeId] == true
                                  ? Icons.pause
                                  : Icons.play_arrow)
                              : EpisodeService.isPlaying
                                  ? Icons.pause
                                  : Icons.download,
                          color: AppColors.color3,
                        ),
                        onPressed: () {
                          if (isDownloaded) {
                            _togglePlayPause(episodeId);
                          } else {
                            _downloadEpisode(episode);
                          }
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Future<void> _downloadEpisode(Map<String, dynamic> episode) async {
    final episodeId = episode['id'];
    final url = '${Network.baseUrl}/${episode['url']}';
    final bookId = widget.audioBook['id'];

    setState(() {
      _downloadingIds.add(episodeId);
      _downloadProgress[episodeId] = 0.0;
    });

    await EpisodeService.downloadEpisode(
      bookId: bookId,
      episodeId: episodeId,
      url: url,
      onProgress: (progress) {
        setState(() {
          _downloadProgress[episodeId] = progress;
        });
      },
    );

    setState(() {
      _downloadingIds.remove(episodeId);
    });
  }

  void _togglePlayPause(int episodeId) {
    setState(() {
      if (_isPlaying[episodeId] == true) {
        _isPlaying[episodeId] = false;
        EpisodeService.pauseEpisode(episodeId); // Now calls pauseEpisode
      } else {
        _isPlaying[episodeId] = true;
        EpisodeService.playEpisode(widget.audioBook['id'],
            episodeId); // Now calls playEpisode with the bookId
      }
    });
  }
}

import 'package:bookreader/constants/logger.dart';
import 'package:bookreader/widgets/loading_widget.dart';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:bookreader/widgets/audio_controlls.dart';
import 'package:bookreader/widgets/audio_palyer_header.dart';
import 'package:bookreader/widgets/error_boundary.dart';
import 'package:bookreader/widgets/progress_bar.dart';
import 'package:bookreader/widgets/volume_controll.dart';
import '../services/audio_player_service.dart';
import '../constants/styles.dart';

class DownloadedAudioPlayerScreen extends StatefulWidget {
  final String title;
  final String imagePath;
  final Map<String, String> downloadedEpisode; // Accepting a single episode

  const DownloadedAudioPlayerScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.downloadedEpisode, // Single episode
  });

  @override
  State<DownloadedAudioPlayerScreen> createState() =>
      _DownloadedAudioPlayerScreenState();
}

class _DownloadedAudioPlayerScreenState
    extends State<DownloadedAudioPlayerScreen> {
  late final AudioPlayerService _audioService;
  double _volume = 0.5;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioService = AudioPlayerService();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final success = await _audioService.initialize();
    if (!success) {
      Logger.error('Failed to initialize audio player');
      return;
    }

    final episodePath = widget.downloadedEpisode['path'];
    if (episodePath != null) {
      await _audioService.player.setAudioSource(
        AudioSource.uri(Uri.file(episodePath)),
      );
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _adjustVolume(double newVolume) async {
    await _audioService.setVolume(newVolume);
    setState(() {
      _volume = newVolume;
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Widget _buildAudioPlayer() {
    final episodeTitle = widget.downloadedEpisode['title'];

    return Column(
      children: [
        AudioPlayerHeader(
          title: widget.title,
          imagePath: widget.imagePath,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Text(
                "Playing: $episodeTitle",
                style: AppTextStyles.bodyText,
              ),
              ProgressBar(player: _audioService.player),
              AudioControls(
                player: _audioService.player,
                onPrevious: () {},
                onNext: () {},
                onPlayPause: _audioService.togglePlay,
              ),
              VolumeControl(
                volume: _volume,
                onVolumeChanged: _adjustVolume,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
        ),
        body: const Center(
          child: LoadingWidget(),
        ),
      );
    }

    return ErrorBoundary(
      fallbackTitle: 'Audio Player Error',
      fallbackMessage:
          'There was an error playing the audio. Please try again.',
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return _buildAudioPlayer(); // Show the player in the modal sheet
                },
              );
            },
            child: Text('Play Episode'),
          ),
        ),
      ),
    );
  }
}

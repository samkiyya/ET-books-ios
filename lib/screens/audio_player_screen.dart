import 'package:book_mobile/constants/logger.dart';
import 'package:book_mobile/widgets/audio_controlls.dart';
import 'package:book_mobile/widgets/audio_palyer_header.dart';
import 'package:book_mobile/widgets/episode_list.dart';
import 'package:book_mobile/widgets/error_boundary.dart';
import 'package:book_mobile/widgets/loading_widget.dart';
import 'package:book_mobile/widgets/volume_controll.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_player_service.dart';
import '../widgets/progress_bar.dart';
import '../constants/constants.dart';
import '../constants/styles.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> audioBook;

  const AudioPlayerScreen({super.key, required this.audioBook});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioPlayerService _audioService;
  double _volume = 0.5;
  int _currentTrackIndex = 0;
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

    await _audioService.setPlaylist(
      widget.audioBook['audios'] as List<dynamic>,
      Network.baseUrl,
    );

    _audioService.player.currentIndexStream.listen((index) {
      if (index != null) {
        setState(() {
          _currentTrackIndex = index;
        });
      }
    });

    setState(() {
      _isInitialized = true;
    });
  }

  void _playPreviousTrack() {
    if (_currentTrackIndex > 0) {
      _audioService.player.seekToPrevious();
    }
  }

  void _playNextTrack() {
    if (_currentTrackIndex < (widget.audioBook['audios'] as List).length - 1) {
      _audioService.player.seekToNext();
    }
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
    final audios = widget.audioBook['audios'] as List<dynamic>;
    final bool hasEpisodes = audios.isNotEmpty;

    if (!hasEpisodes) {
      return Center(
        child: Text(
          "No audio episodes available for this book.",
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        AudioPlayerHeader(
          title: widget.audioBook['title'],
          imagePath: widget.audioBook['imageFilePath'],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              StreamBuilder<SequenceState?>(
                stream: _audioService.player.sequenceStateStream,
                builder: (context, snapshot) {
                  final currentTrack = snapshot.data?.currentSource?.tag ?? '';
                  return Text(
                    "Playing: $currentTrack",
                    style: AppTextStyles.bodyText,
                  );
                },
              ),
              ProgressBar(player: _audioService.player),
              AudioControls(
                player: _audioService.player,
                onPrevious: _playPreviousTrack,
                onNext: _playNextTrack,
                onPlayPause: _audioService.togglePlay,
              ),
              VolumeControl(
                volume: _volume,
                onVolumeChanged: _adjustVolume,
              ),
            ],
          ),
        ),
        EpisodeList(
          episodes: audios,
          player: _audioService.player,
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
            widget.audioBook['title'],
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
        body: _buildAudioPlayer(),
      ),
    );
  }
}

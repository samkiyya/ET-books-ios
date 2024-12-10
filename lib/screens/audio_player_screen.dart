import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/styles.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> audioBook;

  const AudioPlayerScreen({super.key, required this.audioBook});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 0.5;
  int _currentTrackIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Initialize the player listeners
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });
  }

  Future<void> _playPauseAudio(String url) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource("${Network.baseUrl}/$url"));
    }
  }

  void _playNextTrack() {
    if (_currentTrackIndex < widget.audioBook['audios'].length - 1) {
      setState(() {
        _currentTrackIndex++;
        _playPauseAudio(widget.audioBook['audios'][_currentTrackIndex]['url']);
      });
    }
  }

  void _playPreviousTrack() {
    if (_currentTrackIndex > 0) {
      setState(() {
        _currentTrackIndex--;
        _playPauseAudio(widget.audioBook['audios'][_currentTrackIndex]['url']);
      });
    }
  }

  Future<void> _seekToPosition(double seconds) async {
    await _audioPlayer.seek(Duration(seconds: seconds.toInt()));
  }

  Future<void> _adjustVolume(double newVolume) async {
    await _audioPlayer.setVolume(newVolume);
    setState(() {
      _volume = newVolume;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final audios = widget.audioBook['audios'] as List<dynamic>;
// Check if there are no audio files
    final bool hasEpisodes = audios.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.audioBook['title'],
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.color1,
      ),
      body: hasEpisodes
          ? Column(
              children: [
                // Cover Image
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        "${Network.baseUrl}/${widget.audioBook['imageFilePath']}",
                        width: width * 0.8,
                        height: height * 0.3,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.broken_image,
                            size: width * 0.2,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Audio Player Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        "Playing: ${audios[_currentTrackIndex]['episode']}",
                        style: AppTextStyles.bodyText,
                      ),
                      Slider(
                        min: 0,
                        max: _duration.inSeconds.toDouble(),
                        value: _position.inSeconds.toDouble(),
                        onChanged: _seekToPosition,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _position.toString().split('.')[0],
                            style: AppTextStyles.bodyText,
                          ),
                          Text(
                            _duration.toString().split('.')[0],
                            style: AppTextStyles.bodyText,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            iconSize: 40,
                            color: AppColors.color2,
                            onPressed: _playPreviousTrack,
                          ),
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                            iconSize: 60,
                            color: AppColors.color2,
                            onPressed: () => _playPauseAudio(
                              audios[_currentTrackIndex]['url'],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            iconSize: 40,
                            color: AppColors.color2,
                            onPressed: _playNextTrack,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.volume_down,
                              color: AppColors.color2),
                          Expanded(
                            child: Slider(
                              min: 0,
                              max: 1,
                              value: _volume,
                              onChanged: _adjustVolume,
                            ),
                          ),
                          const Icon(Icons.volume_up, color: AppColors.color2),
                        ],
                      ),
                    ],
                  ),
                ),

                // List of Episodes
                Expanded(
                  child: ListView.builder(
                    itemCount: audios.length,
                    itemBuilder: (context, index) {
                      final audio = audios[index];
                      return Card(
                        color: AppColors.color2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.music_note,
                              color: AppColors.color1),
                          title: Text(
                            audio['episode'],
                            style: AppTextStyles.heading2,
                          ),
                          onTap: () {
                            setState(() {
                              _currentTrackIndex = index;
                              _playPauseAudio(audio['url']);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                "No audio episodes available for this book.",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}

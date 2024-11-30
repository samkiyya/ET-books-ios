import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/widgets/custom_nav_bar.dart';

class AudioDetailScreen extends StatefulWidget {
  final Map<String, dynamic> audioBook;

  const AudioDetailScreen({super.key, required this.audioBook});

  @override
  State<AudioDetailScreen> createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends State<AudioDetailScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to audio player states
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

  Future<void> _playPauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer
          .play(UrlSource("${Network.baseUrl}/${widget.audioBook['url']}"));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.audioBook['episode'],
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.color2,
                    AppColors.color1,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(width * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Audio Image
                    Center(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            '${Network.baseUrl}/${widget.audioBook['imageFilePath']}',
                            width: width * 0.6,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return Icon(
                                Icons.broken_image, // Alternative icon
                                size: width * 0.2,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),

                    // Audio Details
                    Text(
                      "Episode: ${widget.audioBook['episode']}",
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.color3,
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Text(
                      "Book Title: ${widget.audioBook['bookTitle']}",
                      style: const TextStyle(color: AppColors.color3),
                    ),
                    SizedBox(height: height * 0.03),
                    Text(
                      "Created At: ${widget.audioBook['createdAt']}",
                      style: const TextStyle(color: AppColors.color3),
                    ),
                    SizedBox(height: height * 0.03),

                    // Audio Player Controls
                    Column(
                      children: [
                        Slider(
                          min: 0,
                          max: _duration.inSeconds.toDouble(),
                          value: _position.inSeconds.toDouble(),
                          onChanged: (value) async {
                            final position = Duration(seconds: value.toInt());
                            await _audioPlayer.seek(position);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                // _isPlaying ? Icons.pause : Icons.play_arrow,
                                Icons.skip_previous,
                                color: AppColors.color3,
                              ),
                              iconSize: width * 0.09,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: AppColors.color3,
                              ),
                              iconSize: width * 0.09,
                              onPressed: _playPauseAudio,
                            ),
                            IconButton(
                              icon: const Icon(
                                // _isPlaying ? Icons.pause : Icons.play_arrow,
                                Icons.skip_next,
                                color: AppColors.color3,
                              ),
                              iconSize: width * 0.09,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                // _isPlaying ? Icons.pause : Icons.play_arrow,
                                Icons.volume_up,
                                color: AppColors.color3,
                              ),
                              iconSize: width * 0.09,
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Text(
                          "${_position.toString().split('.')[0]} / ${_duration.toString().split('.')[0]}",
                          style: const TextStyle(color: AppColors.color3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: 2,
          onTap: (index) {
            Navigator.pop(context); // Navigate based on index
          },
        ),
      ),
    );
  }
}

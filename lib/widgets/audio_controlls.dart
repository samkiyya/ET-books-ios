import 'package:bookreader/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioControls extends StatelessWidget {
  final AudioPlayer player;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPlayPause;

  const AudioControls({
    super.key,
    required this.player,
    required this.onPrevious,
    required this.onNext,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 40,
          color: AppColors.color2,
          onPressed: onPrevious,
        ),
        StreamBuilder<bool>(
          stream: player.playingStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 60,
              color: AppColors.color2,
              onPressed: onPlayPause,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 40,
          color: AppColors.color2,
          onPressed: onNext,
        ),
      ],
    );
  }
}

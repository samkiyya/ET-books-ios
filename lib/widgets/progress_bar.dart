import 'package:book_mobile/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ProgressBar extends StatelessWidget {
  final AudioPlayer player;

  const ProgressBar({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, snapshot) {
        final duration = snapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            return Column(
              children: [
                Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) {
                    player.seek(Duration(seconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      position.toString().split('.')[0],
                      style: AppTextStyles.bodyText,
                    ),
                    Text(
                      duration.toString().split('.')[0],
                      style: AppTextStyles.bodyText,
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

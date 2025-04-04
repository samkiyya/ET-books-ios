import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../constants/styles.dart';

class EpisodeList extends StatelessWidget {
  final List<dynamic> episodes;
  final AudioPlayer player;

  const EpisodeList({
    super.key,
    required this.episodes,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          final episode = episodes[index];
          return Card(
            color: AppColors.color2,
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.music_note,
                color: AppColors.color1,
              ),
              title: Text(
                episode['episode'],
                style: AppTextStyles.heading2,
              ),
              onTap: () {
                player.seek(Duration.zero, index: index);
              },
            ),
          );
        },
      ),
    );
  }
}

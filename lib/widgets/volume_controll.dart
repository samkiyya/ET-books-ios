import 'package:bookreader/constants/styles.dart';
import 'package:flutter/material.dart';

class VolumeControl extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const VolumeControl({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.volume_down, color: AppColors.color2),
        Expanded(
          child: Slider(
            min: 0,
            max: 1,
            value: volume,
            onChanged: onVolumeChanged,
          ),
        ),
        const Icon(Icons.volume_up, color: AppColors.color2),
      ],
    );
  }
}

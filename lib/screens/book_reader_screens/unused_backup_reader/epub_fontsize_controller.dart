import 'package:flutter/material.dart';


class ControlsSection extends StatelessWidget {
  final double fontSize;
  final ValueChanged<double> onFontSizeChange;

  const ControlsSection({
    super.key,
    required this.fontSize,
    required this.onFontSizeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Font Size: ${fontSize.toInt()}'),
              Expanded(
                child: Slider(
                  min: 12.0,
                  max: 24.0,
                  value: fontSize,
                  divisions: 12,
                  onChanged: onFontSizeChange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

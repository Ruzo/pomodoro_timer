import 'package:flutter/material.dart';

/// Text Widget for display of timer counter
class CounterText extends StatelessWidget {
  /// Counter as text
  final String text;

  /// Instance of Text Widget for display of timer counter
  const CounterText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withAlpha((0.85 * 255).round()),
        fontSize: 45,
        fontFeatures: const [
          FontFeature.tabularFigures(),
        ],
      ),
    );
  }
}

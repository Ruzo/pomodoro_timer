import 'dart:ui';

import 'package:flutter/material.dart';

/// Text Widget for display of timer counter
class CounterText extends StatelessWidget {
  /// Counter as text
  final String text;

  /// Instance of Text Widget for display of timer counter
  const CounterText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withOpacity(.85),
        fontSize: 45,
        fontFeatures: const [
          FontFeature.tabularFigures(),
        ],
      ),
    );
  }
}

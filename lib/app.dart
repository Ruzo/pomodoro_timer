import 'package:flutter/material.dart';
import 'package:pomodoro_timer/app_theme.dart';
import 'package:pomodoro_timer/timer/timer_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: LayoutBuilder(
        builder: (context, constraints) {
          return TimerScreen();
        },
      ),
    );
  }
}

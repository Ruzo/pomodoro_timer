import 'package:flutter/material.dart';
import 'package:pomodoro_timer/ui/app_theme.dart';
import 'package:pomodoro_timer/ui/timer/timer_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: TimerScreen(),
    );
  }
}

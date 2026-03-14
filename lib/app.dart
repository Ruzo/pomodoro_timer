import 'package:flutter/material.dart';
import 'package:pomodoro_timer/app_theme.dart';
import 'package:pomodoro_timer/router.dart';

/// A pomodoro system timer
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: darkTheme,
      routerConfig: router,
    );
  }
}

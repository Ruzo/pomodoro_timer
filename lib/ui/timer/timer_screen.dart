import 'package:flutter/material.dart';
import 'package:pomodoro_timer/ui/timer/current_task.dart';

class TimerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Theme.of(context).backgroundColor,
          title: Center(
            child: Text(
              'Pomodoro Timer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CurrentTask(),
            ],
          ),
        ),
      ),
    );
  }
}

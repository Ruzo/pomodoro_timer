import 'package:flutter/material.dart';
import 'package:pomodoro_timer/ui/timer/current_task.dart';
import 'package:pomodoro_timer/ui/timer/timer_display.dart';

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
              'Pomodoro timer',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              // width: 385.0,
              // height: 832.0,
              child: Column(
                children: [
                  CurrentTask(),
                  Padding(padding: const EdgeInsets.all(30.0)),
                  TimerDisplay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

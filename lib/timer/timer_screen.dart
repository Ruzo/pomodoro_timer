import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/timer/ui/controls.dart';
import 'package:pomodoro_timer/timer/ui/current_task.dart';
import 'package:pomodoro_timer/timer/ui/pomodoro_indicator.dart';
import 'package:pomodoro_timer/timer/ui/timer_display.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Theme.of(context).backgroundColor,
          title: const Center(
            child: Text(
              'Pomodoro timer',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FutureBuilder(
                  future: GetIt.I.allReady(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          CurrentTask(),
                          const Padding(padding: EdgeInsets.all(30.0)),
                          TimerDisplay(),
                          const Padding(padding: EdgeInsets.all(20.0)),
                          PomodoroIndicator(),
                          const Padding(padding: EdgeInsets.all(30.0)),
                          Controls(),
                        ],
                      );
                    } else {
                      return const CircularProgressIndicator.adaptive();
                    }
                  }),
            ),
          ),
        ),
      ),
    );
  }
}

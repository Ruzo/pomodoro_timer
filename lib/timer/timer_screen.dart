import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:pomodoro_timer/tasks/_model/Session.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
import 'package:pomodoro_timer/timer/widgets/controls.dart';
import 'package:pomodoro_timer/timer/widgets/current_task.dart';
import 'package:pomodoro_timer/timer/widgets/pomodoro_indicator.dart';
import 'package:pomodoro_timer/timer/widgets/timer_display.dart';

class TimerScreen extends StatelessWidget with GetItMixin {
  @override
  Widget build(BuildContext context) {
    var ts = get<TasksService>();
    final isInitialized = watchX((TasksService s) => s.dataIsInitialized);
    List<Session> _sessions = ts.sessions;
    final _currentSession = watchX((TasksService s) => s.currentSessionIndex);

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
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: !isInitialized
                  ? CircularProgressIndicator()
                  : Container(
                      child: Column(
                        children: [
                          CurrentTask(
                            title: 'Work on Pomodoro timer',
                          ),
                          Padding(padding: const EdgeInsets.all(30.0)),
                          TimerDisplay(
                            totalTime: _sessions[_currentSession].duration,
                            session: _sessions[_currentSession],
                          ),
                          Padding(padding: const EdgeInsets.all(20.0)),
                          PomodoroIndicator(
                            sessions: _sessions,
                            currentSession: _currentSession,
                          ),
                          Padding(padding: const EdgeInsets.all(30.0)),
                          Controls(),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

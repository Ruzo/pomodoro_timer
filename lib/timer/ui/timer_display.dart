import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
import 'package:pomodoro_timer/timer/_manager/timer_manager.dart';
// import 'package:pomodoro_timer/timer/_services/timer_service.dart';
import 'package:pomodoro_timer/timer/ui/timer_painter.dart';
import 'package:pomodoro_timer/timer/ui/total_time_text.dart';

import 'counter_text.dart';

/// Widget box enclosing timer CustomPaint widget
class TimerDisplay extends StatelessWidget with GetItMixin {
  /// Instance of widget box enclosing timer CustomPaint widget
  TimerDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.fitWidth,
      child: SizedBox(
        width: 300,
        height: 300,
        child: TimerWidget(),
      ),
    );
  }
}

/// Widget including CustomPaint and GestureDetector for timer display
class TimerWidget extends StatelessWidget with GetItMixin {
  /// Instance of widget enclosing timer progress indicator and counter
  TimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _currentTime = watchX((TimerManager tm) => tm.getCurrentTime);
    var _sessions = GetIt.I<TasksService>().sessions;
    final _currentSession = watchX((TasksService s) => s.currentSessionIndex);
    final _session = _sessions[_currentSession];
    final _totalDuration = _sessions[_currentSession].duration;
    final _dragStarted = watchX((TimerManager tm) => tm.dragStarted);
    final _dragPosition = watchX((TimerManager tm) => tm.updateDragPosition);
    final _dragging = watchX((TimerManager tm) => tm.dragging);
    // final _taskLimitsReached = watchX((TimerManager tm) => tm.taskLimitsReached);
    var timeChars = _currentTime.toString().split('.').first.split(':').sublist(1);

    // dragStarted does not work with painter hitTest unless added to shoulRepaint!
    return GestureDetector(
      child: CustomPaint(
        key: const Key('painter'),
        isComplex: true,
        painter: TimerPainter(
          totalMs: _totalDuration.inMilliseconds,
          currentMs: _currentTime.inMilliseconds,
          sessionType: _session.type,
          dragPosition: _dragPosition,
          dragStarted: _dragStarted,
          dragging: _dragging,
          // limitsReached: _taskLimitsReached,
        ),
        child: IgnorePointer(
          ignoring: true,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(padding: EdgeInsets.all(15)),
                  CounterText(text: timeChars.join(':')),
                  TotalTimeText(
                    totalMinutes: _totalDuration.inMinutes,
                    session: _session,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onPanStart: (details) {
        get<TimerManager>().dragStarted(true);
      },
      onPanUpdate: (details) {
        get<TimerManager>().updateDragPosition(details.localPosition);
      },
      onPanEnd: (details) {
        get<TimerManager>().dragStarted(false);
      },
    );
  }
}

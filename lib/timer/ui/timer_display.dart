import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
import 'package:pomodoro_timer/timer/_manager/timer_manager.dart';
import 'package:pomodoro_timer/timer/ui/timer_painter.dart';
import 'package:pomodoro_timer/timer/ui/total_time_text.dart';

import 'counter_text.dart';

/// Widget box enclosing timer CustomPaint widget
class TimerDisplay extends StatelessWidget {
  /// Instance of widget box enclosing timer CustomPaint widget
  const TimerDisplay({super.key});

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
class TimerWidget extends StatelessWidget {
  /// Instance of widget enclosing timer progress indicator and counter
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var tm = GetIt.I<TimerManager>();
    var ts = GetIt.I<TasksService>();

    final currentTime = tm.getCurrentTime.watch(context).inMilliseconds;
    final sessions = ts.sessions.watch(context);
    final currentSession = ts.currentSessionIndex.watch(context);

    if (sessions.isEmpty) return const SizedBox.shrink();

    var session = sessions[currentSession];
    var totalDuration = session.duration.inMilliseconds;

    bool dragStarted = tm.dragStarted.watch(context);
    Offset dragPosition = tm.updateDragPosition.watch(context);
    bool dragging = tm.dragging.watch(context);

    var timeChars = Duration(milliseconds: currentTime).toString().split('.').first.split(':').sublist(1);

    // dragStarted does not work with painter hitTest unless added to shoulRepaint!
    return GestureDetector(
      child: CustomPaint(
        key: const Key('painter'),
        isComplex: true,
        painter: TimerPainter(
          totalMs: totalDuration,
          currentMs: currentTime,
          sessionType: session.type,
          dragPosition: dragPosition,
          dragStarted: dragStarted,
          dragging: dragging,
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
                    totalMinutes: Duration(milliseconds: totalDuration).inMinutes,
                    session: session,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onPanStart: (details) {
        tm.setDragStartedState(true);
      },
      onPanUpdate: (details) {
        tm.setDragPosition(details.localPosition);
      },
      onPanEnd: (details) {
        tm.setDragStartedState(false);
      },
    );
  }
}

// import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_model/Session.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';
import 'package:pomodoro_timer/timer/widgets/timer_painter.dart';

class TimerDisplay extends StatelessWidget with GetItMixin {
  final Duration totalTime;
  final Session session;

  TimerDisplay({
    Key? key,
    required this.totalTime,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentTime = watchX((TimerService timer) => timer.currentTime);
    final isRunning = watchX((TimerService timer) => timer.timerIsRunning);

    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.fitWidth,
      child: SizedBox(
        width: 300,
        height: 300,
        child: TimerWidget(
          totalDuration: totalTime,
          currentDuration: currentTime,
          session: session,
          isRunning: isRunning,
        ),
      ),
    );
  }
}

class TimerWidget extends StatelessWidget {
  final Duration totalDuration;
  final Duration currentDuration;
  final Session session;
  final bool isRunning;

  final int total;
  final int current;
  final List<String> timeChars;

  TimerWidget({
    Key? key,
    required this.totalDuration,
    required this.currentDuration,
    required this.session,
    required this.isRunning,
  })  : total = totalDuration.inMilliseconds,
        current = currentDuration.inMilliseconds,
        timeChars = currentDuration.toString().split('.').first.split(':').sublist(1),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => print('tapped!'),
      onLongPressStart: (details) {
        print(details.localPosition);
      },
      onLongPressMoveUpdate: (details) {
        print(details.localOffsetFromOrigin);
      },
      child: CustomPaint(
        key: Key('painter'),
        isComplex: true,
        painter: TimerPainter(
          totalMs: total,
          currentMs: current,
          sessionType: session.type,
        ),
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.all(15)),
                  CounterText(text: timeChars.join(':')),
                  TotalTimeText(
                    totalMinutes: totalDuration.inMinutes,
                    session: session,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  final String text;

  const CounterText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withOpacity(.85),
        fontSize: 45,
        fontFeatures: [
          FontFeature.tabularFigures(),
        ],
      ),
    );
  }
}

class TotalTimeText extends StatelessWidget {
  final int totalMinutes;
  final Session session;

  TotalTimeText({Key? key, required this.totalMinutes, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String s = totalMinutes > 1 ? 's' : '';
    final String text = '${totalMinutes.toString()} min$s';

    return Text(
      '$text',
      style: TextStyle(
        fontSize: 20,
        color: (session.type == SessionType.pomodoro) ? kPrimaryColor.withOpacity(.85) : kAlternateColor,
      ),
    );
  }
}

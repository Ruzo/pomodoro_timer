import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/ui/timer/timer_painter.dart';

class TimerDisplay extends StatefulWidget {
  @override
  _TimerDisplayState createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  Duration _currentTime = Duration.zero;
  Duration _totalTime = Duration(minutes: 1);
  bool _firstBuild = true;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_firstBuild) {
      _stopwatch.start();
      setState(() {
        _timer = Timer.periodic(Duration(milliseconds: 1), (_) {
          setState(() {
            _currentTime = _stopwatch.elapsed;
            if (_currentTime >= _totalTime) {
              _stopwatch.stop();
              _timer.cancel();
            }
          });
        });
        _firstBuild = false;
      });
    }
    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.fitWidth,
      child: SizedBox(
        width: 300,
        height: 300,
        child: _paintTimer(
          _totalTime,
          _currentTime,
        ),
      ),
    );
  }
}

Widget _paintTimer(Duration totalDuration, Duration currentDuration) {
  int total = totalDuration.inMilliseconds;
  int current = currentDuration.inMilliseconds;
  List<String> timeChars = currentDuration.toString().split('.').first.split(':').sublist(1);

  Widget counterText(String text) {
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

  return CustomPaint(
    painter: TimerPainter(
      totalMs: total,
      currentMs: current,
    ),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: counterText(timeChars.join(':')),
      ),
    ),
  );
}

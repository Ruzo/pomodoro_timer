import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/constants.dart';

class TimerInterface extends StatefulWidget {
  @override
  _TimerInterfaceState createState() => _TimerInterfaceState();
}

class _TimerInterfaceState extends State<TimerInterface> {
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
        fontSize: 50,
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

class TimerPainter extends CustomPainter {
  final int totalMs;
  final int currentMs;
  double progressSweepAngle = 0.0;
  double currentAngle = 0.0;

  TimerPainter({this.totalMs = 0, this.currentMs = 0}) {
    progressSweepAngle = ((2 * pi) / totalMs) * currentMs;
    currentAngle = currentMs / totalMs;
  }

  // Start and sweep
  final double startAngle = 0.0;
  final double sweepAngle = (2 * pi);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = min(size.width, size.height) / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    canvas.translate(centerX, centerY);
    canvas.rotate(1.5 * pi);
    canvas.translate(-centerX, -centerY);

    //# Background layer
    Paint backgroundPaint = Paint()..color = kAccentColor.withAlpha(30);
    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    //# Background progress indicator filler
    Paint timerBkgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.butt
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        tileMode: TileMode.clamp,
        colors: [kBackgroundLiteColor, Colors.transparent],
        stops: [
          currentAngle,
          currentAngle,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius - 20),
      );

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius - 20,
      ),
      startAngle,
      sweepAngle,
      false,
      timerBkgPaint,
    );

    //# Progress Indicator line
    Paint progressLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.butt
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        colors: [
          kPrimaryColor.withOpacity(.05),
          kPrimaryColor,
          kPrimaryColor,
          Colors.transparent,
        ],
        stops: [
          0.0,
          currentAngle / 2,
          currentAngle,
          currentAngle,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 35))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 35),
      startAngle,
      sweepAngle,
      false,
      progressLinePaint,
    );

    //# Center circle with glow shadow
    Paint centerCirclePaint = Paint()
      ..color = kBackgroundColor
      ..style = PaintingStyle.fill;
    Paint centerCircleGlowPaint = Paint()
      ..color = kPrimaryColor.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(
      center,
      radius - 40,
      centerCircleGlowPaint,
    );
    canvas.drawCircle(
      center,
      radius - 40,
      centerCirclePaint,
    );

    //# Thumb @ Progress Indicator line pos
    double radians = progressSweepAngle;

    Paint progressPosCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Paint progressPosCircleBorderPaint = Paint()
      ..color = kPrimaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, 1);

    canvas.drawShadow(
      Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(
              center.dx + (radius - 35) * cos(radians),
              center.dy + (radius - 35) * sin(radians),
            ),
            radius: 11,
          ),
        ),
      kBackgroundColor.withOpacity(.5),
      1,
      false,
    );

    canvas.drawCircle(
      Offset(
        center.dx + (radius - 35) * cos(radians),
        center.dy + (radius - 35) * sin(radians),
      ),
      9,
      progressPosCirclePaint,
    );

    canvas.drawCircle(
      Offset(
        center.dx + (radius - 35) * cos(radians),
        center.dy + (radius - 35) * sin(radians),
      ),
      9,
      progressPosCircleBorderPaint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return currentMs != oldDelegate.currentMs;
  }
}

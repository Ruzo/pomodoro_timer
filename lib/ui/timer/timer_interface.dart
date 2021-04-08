import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/constants.dart';

class TimerInterface extends StatefulWidget {
  @override
  _TimerInterfaceState createState() => _TimerInterfaceState();
}

class _TimerInterfaceState extends State<TimerInterface> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.fitWidth,
      child: SizedBox(
        width: 300,
        height: 300,
        child: CustomPaint(
          painter: TimerPainter(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '15:00',
                style: TextStyle(
                  color: Colors.white.withOpacity(.85),
                  fontSize: 50,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  // Current time values
  Duration mins = Duration(minutes: 20);
  Duration currentTime = Duration(minutes: 15, seconds: 0, milliseconds: 0);

  // Start, sweep and current angles
  double startAngle = 0.0;
  double sweepAngle = (2 * pi);
  double currentAngle(Duration totalTime, Duration currentTimePos) {
    double angle = currentTimePos.inMilliseconds / totalTime.inMilliseconds;
    return angle;
  }

  double progressSweepAngle(Duration totalTime, Duration currentTimePos) {
    double progressAngle = ((2 * pi) / totalTime.inMilliseconds) * currentTimePos.inMilliseconds;
    print(progressAngle);
    return progressAngle;
  }

  @override
  void paint(Canvas canvas, Size size) {
    print(size);
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width, size.height) / 2;

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(1.5 * pi);
    canvas.translate(-(size.width / 2), -(size.height / 2));

    //# Background layer
    Paint backgroundPaint = Paint()..color = kAccentColor.withAlpha(30);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
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
        stops: [currentAngle(mins, currentTime), currentAngle(mins, currentTime)],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 20));

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
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
        colors: [Colors.transparent, kPrimaryColor, kPrimaryColor, Colors.transparent],
        stops: [
          0.0,
          currentAngle(mins, currentTime) / 2,
          currentAngle(mins, currentTime),
          currentAngle(mins, currentTime),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 35));

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

    //# Circle @ Progress Indicator line pos
    double radians = progressSweepAngle(mins, currentTime);

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

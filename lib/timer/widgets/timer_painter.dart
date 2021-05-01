import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/constants.dart';

class TimerPainter extends CustomPainter {
  final int totalMs;
  final int currentMs;
  final SessionType sessionType;
  final Offset dragPosition;
  final bool dragStarted;
  double progressSweepAngle = 0.0;
  double currentAngle = 0.0;
  Path _hitPath = Path();

  TimerPainter({
    required this.totalMs,
    required this.currentMs,
    required this.sessionType,
    required this.dragPosition,
    required this.dragStarted,
  }) {
    progressSweepAngle = ((kSweepAngle) / totalMs) * currentMs;
    currentAngle = currentMs / totalMs;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = min(size.width, size.height) / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double timerBkgRadius = radius - 20;
    final double progressLineRadius = radius - 35;
    final double centerCircleRadius = radius - 40;
    double thumbRadians = progressSweepAngle;

    // move 0 degree to top
    canvas.translate(centerX, centerY);
    canvas.rotate(1.5 * pi);
    canvas.translate(-centerX, -centerY);

    //# Background layer
    final Paint backgroundPaint = Paint()..color = kAccentColor.withAlpha(30);
    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    //# Background progress indicator filler
    final Paint timerBkgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.butt
      ..shader = SweepGradient(
        startAngle: kStartAngle,
        endAngle: kSweepAngle,
        tileMode: TileMode.clamp,
        colors: [kBackgroundLiteColor, Colors.transparent],
        stops: [
          currentAngle,
          currentAngle,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: timerBkgRadius),
      );

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: timerBkgRadius,
      ),
      kStartAngle,
      kSweepAngle,
      false,
      timerBkgPaint,
    );

    //# Progress Indicator line
    Color progressColor = sessionType == SessionType.pomodoro ? kPrimaryColor : kAlternateColor;
    final Paint progressLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.butt
      ..shader = SweepGradient(
        startAngle: kStartAngle,
        endAngle: kSweepAngle,
        colors: [
          progressColor.withOpacity(.05),
          progressColor,
          progressColor,
          Colors.transparent,
        ],
        stops: [
          kStartAngle,
          currentAngle / 2,
          currentAngle,
          currentAngle,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: progressLineRadius))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: progressLineRadius),
      kStartAngle,
      kSweepAngle,
      false,
      progressLinePaint,
    );

    //# Center circle with glow shadow
    final Paint centerCirclePaint = Paint()
      ..color = kBackgroundColor
      ..style = PaintingStyle.fill;
    final Paint centerCircleGlowPaint = Paint()
      ..color = progressColor.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(
      center,
      centerCircleRadius,
      centerCircleGlowPaint,
    );
    canvas.drawCircle(
      center,
      centerCircleRadius,
      centerCirclePaint,
    );

    //# Thumb @ Progress Indicator line pos
    if (dragStarted && dragPosition.distance > 0.0) {
      final double deltaX = (300 - dragPosition.dy) - center.dx;
      final double deltaY = dragPosition.dx - center.dy;
      thumbRadians = atan2(deltaY, deltaX);
      // print('dragStarted calc: deltaX: $deltaX, deltaY: $deltaY, rdX: $thumbRadians, rdY: $thumbRadians');
    }
    final double thumbCenterDx = center.dx + (progressLineRadius * cos(thumbRadians));
    final double thumbCenterDy = center.dy + (progressLineRadius * sin(thumbRadians));
    // print('ThumbX: $thumbCenterDx, ThumbY: $thumbCenterDy');
    final Paint progressPosCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint progressPosCircleBorderPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, 1);

    final Paint draggingCircleBorderPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, 1);

    canvas.drawShadow(
      Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(
              thumbCenterDx,
              thumbCenterDy,
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
        thumbCenterDx,
        thumbCenterDy,
      ),
      9,
      progressPosCirclePaint,
    );

    canvas.drawCircle(
      Offset(
        thumbCenterDx,
        thumbCenterDy,
      ),
      9,
      progressPosCircleBorderPaint,
    );
    // print('dragStarted Painter: $dragStarted');
    if (dragStarted) {
      canvas.drawCircle(
        Offset(
          thumbCenterDx,
          thumbCenterDy,
        ),
        20,
        draggingCircleBorderPaint,
      );
    }

    _hitPath = Path()
      ..addOval(
        Rect.fromCircle(
            //! hitTest path Offset does not take canvas translate and rotation into account
            center: Offset(
              center.dx + (progressLineRadius) * sin(thumbRadians),
              center.dy - (progressLineRadius) * cos(thumbRadians),
            ),
            radius: 20),
      );
  }

  @override
  bool hitTest(Offset position) {
    bool _hit = _hitPath.contains(position);
    // print(_hit);
    return _hit;
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return (currentMs != oldDelegate.currentMs) || (dragStarted != oldDelegate.dragStarted);
  }
}

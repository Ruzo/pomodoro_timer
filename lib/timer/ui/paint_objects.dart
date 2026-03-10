import 'package:flutter/material.dart';
import 'package:pomodoro_timer/constants.dart';

//XXX Background layer
void paintBackground(Canvas canvas, Offset center, double radius) {
  var backgroundPaint = Paint()..color = kAccentColor.withAlpha(30);
  canvas.drawCircle(
    center,
    radius,
    backgroundPaint,
  );
}

//XXX Background progress indicator filler
void paintBackgroundProgressIndicator(Offset center, double timerBkgRadius, double currentAngle, Canvas canvas) {
  var timerBkgPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 40
    ..strokeCap = StrokeCap.butt
    ..shader = SweepGradient(
      startAngle: kStartAngle,
      endAngle: kSweepAngle,
      tileMode: TileMode.clamp,
      colors: const [kBackgroundLiteColor, Colors.transparent],
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
}

//XXX Progress Indicator line
Color paintProgressIndicatorLine(
    Offset center, double progressLineRadius, Color progressColor, double currentAngle, Canvas canvas) {
  var progressLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8
    ..strokeCap = StrokeCap.butt
    ..shader = SweepGradient(
      startAngle: kStartAngle,
      endAngle: kSweepAngle,
      colors: [
        progressColor.withValues(alpha: .05),
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
    ).createShader(
      Rect.fromCircle(center: center, radius: progressLineRadius),
    )
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

  canvas.drawArc(
    Rect.fromCircle(center: center, radius: progressLineRadius),
    kStartAngle,
    kSweepAngle,
    false,
    progressLinePaint,
  );
  return progressColor;
}

//XXX Center circle with glow shadow
void paintCenterCircleWithGlowShadow(Color progressColor, Canvas canvas, Offset center, double centerCircleRadius) {
  var centerCirclePaint = Paint()
    ..color = kBackgroundColor
    ..style = PaintingStyle.fill;
  var centerCircleGlowPaint = Paint()
    ..color = progressColor.withValues(alpha: 0.5)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

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
}

//XXX Progress indicator draggable thumb
void paintProgressIndicatorCircleThumb(
    Color progressColor, Canvas canvas, double thumbCenterDx, double thumbCenterDy, bool dragStarted) {
  var progressPosCirclePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  var progressPosCircleBorderPaint = Paint()
    ..color = progressColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 1);

  var draggingCircleBorderPaint = Paint()
    ..color = progressColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 1);

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
    kBackgroundColor.withValues(alpha: .5),
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
}

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/constants.dart';

//XXX Background layer
void paintBackground(Canvas canvas, Offset _center, double _radius) {
  var _backgroundPaint = Paint()..color = kAccentColor.withAlpha(30);
  canvas.drawCircle(
    _center,
    _radius,
    _backgroundPaint,
  );
}

//XXX Background progress indicator filler
void paintBackgroundProgressIndicator(Offset _center, double _timerBkgRadius, double _currentAngle, Canvas canvas) {
  var _timerBkgPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 40
    ..strokeCap = StrokeCap.butt
    ..shader = SweepGradient(
      startAngle: kStartAngle,
      endAngle: kSweepAngle,
      tileMode: TileMode.clamp,
      colors: const [kBackgroundLiteColor, Colors.transparent],
      stops: [
        _currentAngle,
        _currentAngle,
      ],
    ).createShader(
      Rect.fromCircle(center: _center, radius: _timerBkgRadius),
    );

  canvas.drawArc(
    Rect.fromCircle(
      center: _center,
      radius: _timerBkgRadius,
    ),
    kStartAngle,
    kSweepAngle,
    false,
    _timerBkgPaint,
  );
}

//XXX Progress Indicator line
Color paintProgressIndicatorLine(
    Offset _center, double _progressLineRadius, Color _progressColor, double _currentAngle, Canvas canvas) {
  var _progressLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8
    ..strokeCap = StrokeCap.butt
    ..shader = SweepGradient(
      startAngle: kStartAngle,
      endAngle: kSweepAngle,
      colors: [
        _progressColor.withOpacity(.05),
        _progressColor,
        _progressColor,
        Colors.transparent,
      ],
      stops: [
        kStartAngle,
        _currentAngle / 2,
        _currentAngle,
        _currentAngle,
      ],
    ).createShader(
      Rect.fromCircle(center: _center, radius: _progressLineRadius),
    )
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

  canvas.drawArc(
    Rect.fromCircle(center: _center, radius: _progressLineRadius),
    kStartAngle,
    kSweepAngle,
    false,
    _progressLinePaint,
  );
  return _progressColor;
}

//XXX Center circle with glow shadow
void paintCenterCircleWithGlowShadow(Color _progressColor, Canvas canvas, Offset _center, double _centerCircleRadius) {
  var _centerCirclePaint = Paint()
    ..color = kBackgroundColor
    ..style = PaintingStyle.fill;
  var _centerCircleGlowPaint = Paint()
    ..color = _progressColor.withOpacity(0.5)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

  canvas.drawCircle(
    _center,
    _centerCircleRadius,
    _centerCircleGlowPaint,
  );
  canvas.drawCircle(
    _center,
    _centerCircleRadius,
    _centerCirclePaint,
  );
}

//XXX Progress indicator draggable thumb
void paintProgressIndicatorCircleThumb(
    Color _progressColor, Canvas canvas, double _thumbCenterDx, double _thumbCenterDy, bool dragStarted) {
  var _progressPosCirclePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  var _progressPosCircleBorderPaint = Paint()
    ..color = _progressColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 1);

  var _draggingCircleBorderPaint = Paint()
    ..color = _progressColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 1);

  canvas.drawShadow(
    Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(
            _thumbCenterDx,
            _thumbCenterDy,
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
      _thumbCenterDx,
      _thumbCenterDy,
    ),
    9,
    _progressPosCirclePaint,
  );

  canvas.drawCircle(
    Offset(
      _thumbCenterDx,
      _thumbCenterDy,
    ),
    9,
    _progressPosCircleBorderPaint,
  );
  if (dragStarted) {
    canvas.drawCircle(
      Offset(
        _thumbCenterDx,
        _thumbCenterDy,
      ),
      20,
      _draggingCircleBorderPaint,
    );
  }
}

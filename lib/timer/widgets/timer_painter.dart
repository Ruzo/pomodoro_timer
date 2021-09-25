import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_model/session.dart';
import 'package:pomodoro_timer/timer/_manager/timer_manager.dart';
import 'package:pomodoro_timer/timer/_models/dragging_data.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';

enum Momentum { forward, inReverse, forwardZeroCrossed, reverseZeroCrossed }

/// Main painter for timer which rebuilds every tick through currentMs
/// while running.
class TimerPainter extends CustomPainter {
  /// Total time in milliseconds needed to calculate current time position.
  final int totalMs;

  /// Current time in milliseconds for angle of shaders and offset of thumb.
  final int currentMs;

  /// Type of current session (pomodoro or break) to indicate the colors.
  final SessionType sessionType;

  /// The updated offset coords for dragging events.
  final Offset dragPosition;

  /// True for onPanSart event and false for onPanEnd.
  final bool dragStarted;

  /// True for onPanUpdate events
  final bool dragging;

  /// True when limits of current task is reached in order to stop
  /// updating with dragging coords.
  LimitReached limitsReached = LimitReached.none;

  /// Radians calculated later for thumb coords
  double _thumbRadians = 0.0;

  /// Keeping track of previous radians value while dragging for momentum calc
  double _prevRadians = 0.0;

  /// Sweep angle for sweep gradients
  double _currentAngle = 0.0;
  Path _hitPath = Path();

  /// Get TimerManager singleton to set time from dragging coords
  final tm = GetIt.I<TimerManager>();
  final ts = GetIt.I<TimerService>();

  /// CustomPainter for circular timer
  TimerPainter({
    required this.totalMs,
    required this.currentMs,
    required this.sessionType,
    required this.dragPosition,
    required this.dragStarted,
    required this.dragging,
    // required this.limitsReached,
  }) {
    _thumbRadians = ((kSweepAngle) / totalMs) * currentMs;
    _currentAngle = currentMs / totalMs;
    _prevRadians = _thumbRadians;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var _center = size.center(Offset.zero);
    var _radius = min(size.width, size.height) / 2;
    var _centerX = size.width / 2;
    var _centerY = size.height / 2;
    var _timerBkgRadius = _radius - 20;
    var _progressLineRadius = _radius - 35;
    var _centerCircleRadius = _radius - 40;
    limitsReached = tm.taskLimitsReached.value;

    // move 0 degree to top
    canvas.translate(_centerX, _centerY);
    canvas.rotate(1.5 * pi);
    canvas.translate(-_centerX, -_centerY);

    //# Background layer
    var _backgroundPaint = Paint()..color = kAccentColor.withAlpha(30);
    canvas.drawCircle(
      _center,
      _radius,
      _backgroundPaint,
    );

    //# Background progress indicator filler
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

    //# Progress Indicator line
    var _progressColor = sessionType == SessionType.pomodoro //
        ? kPrimaryColor
        : kAlternateColor;
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

    //# Center circle with glow shadow
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

    //# Thumb @ Progress Indicator line pos
    if (dragging) {
      var _deltaX = (300 - dragPosition.dy) - _center.dx;
      var _deltaY = dragPosition.dx - _center.dy;

      var _dragRadians = atan2(_deltaY, _deltaX);
      print('totalMs: $totalMs, currentMs: $currentMs, limitsReached: $limitsReached');

      var _timeRadians = convertToFullCircle(_dragRadians);
      var _momentum = checkMomentum(_prevRadians, _timeRadians);
      print('momentum: $_momentum');

      if (_momentum == null) return;
      if (((_momentum == Momentum.forward || _momentum == Momentum.forwardZeroCrossed) &&
              limitsReached == LimitReached.end) ||
          ((_momentum == Momentum.inReverse || _momentum == Momentum.reverseZeroCrossed) &&
              limitsReached == LimitReached.start)) {
        print('Not setting time from drag');
        return;
      }

      var _draggingTimeInMs = ((totalMs / kSweepAngle) * _timeRadians).toInt();
      print('Setting time from drag');
      tm.setTimeFromDrag(DraggingData(currentTimeInMs: _draggingTimeInMs, momentum: _momentum));
      _prevRadians = _timeRadians;
    } else {
      _prevRadians = _thumbRadians;
    }

    var _thumbCenterDx = _center.dx + (_progressLineRadius * cos(_thumbRadians));
    var _thumbCenterDy = _center.dy + (_progressLineRadius * sin(_thumbRadians));
    // print('ThumbX: $thumbCenterDx, ThumbY: $thumbCenterDy');
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

    _hitPath = Path()
      ..addOval(
        Rect.fromCircle(
            //! hitTest path Offset does not take canvas translate and rotation
            //! into account
            center: Offset(
              _center.dx + (_progressLineRadius) * sin(_thumbRadians),
              _center.dy - (_progressLineRadius) * cos(_thumbRadians),
            ),
            radius: 20),
      );
  }

  @override
  bool hitTest(Offset position) {
    var _hit = _hitPath.contains(position);
    // print(_hit);
    return _hit;
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    // if (limitsReached) return false;
    return (currentMs != oldDelegate.currentMs) ||
        (dragStarted != oldDelegate.dragStarted) ||
        (dragPosition != oldDelegate.dragPosition);
  }

  //TODO: fix prevValue and currentValue issue after zeroCrossed
  Momentum? checkMomentum(double prevValue, double currentValue) {
    print('prevValue: $prevValue, currentValue: $currentValue, changingSession: ${ts.changingSession}');
    if (!ts.changingSession) {
      if (prevValue >= 6.0 && currentValue <= 1.0) return Momentum.forwardZeroCrossed;
      if (prevValue <= 1.0 && currentValue >= 6.0) return Momentum.reverseZeroCrossed;
    }

    if ((prevValue < currentValue) && (limitsReached != LimitReached.start)) {
      return Momentum.forward;
    } else if ((prevValue > currentValue) && (limitsReached != LimitReached.end)) {
      return Momentum.inReverse;
    }
  }

  double convertToFullCircle(double radians) {
    return radians < 0 //
        ? (2 * pi) + radians
        : radians;
  }

  double convertToHalfCircle(double radians) {
    return radians > pi ? (pi - radians) : radians;
  }
}

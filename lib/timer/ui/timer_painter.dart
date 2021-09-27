import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_model/session.dart';
import 'package:pomodoro_timer/timer/_manager/timer_manager.dart';
import 'package:pomodoro_timer/timer/_models/dragging_data.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';
import 'package:pomodoro_timer/timer/ui/paint_objects.dart';

enum Direction { forward, inReverse, forwardZeroCrossed, reverseZeroCrossed }

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

  /// Keeping track of previous radians value while dragging for direction calc
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
    var _progressColor = sessionType == SessionType.pomodoro //
        ? kPrimaryColor
        : kAlternateColor;
    limitsReached = tm.taskLimitsReached.value;

    // move 0 degree to top
    canvas.translate(_centerX, _centerY);
    canvas.rotate(1.5 * pi);
    canvas.translate(-_centerX, -_centerY);

    // Background layer
    paintBackground(canvas, _center, _radius);

    // Background progress indicator filler
    paintBackgroundProgressIndicator(_center, _timerBkgRadius, _currentAngle, canvas);

    // Progress Indicator line
    paintProgressIndicatorLine(_center, _progressLineRadius, _progressColor, _currentAngle, canvas);

    // Center circle with glow shadow
    paintCenterCircleWithGlowShadow(_progressColor, canvas, _center, _centerCircleRadius);

    //XXX Thumb @ Progress Indicator line pos
    if (dragging) {
      var _deltaX = (300 - dragPosition.dy) - _center.dx;
      var _deltaY = dragPosition.dx - _center.dy;

      var _dragRadians = atan2(_deltaY, _deltaX);
      print('totalMs: $totalMs, currentMs: $currentMs, limitsReached: $limitsReached');

      var _timeRadians = convertToFullCircle(_dragRadians);
      var _direction = checkDirection(_prevRadians, _timeRadians);
      print('direction: $_direction');

      if (_direction == null) return;
      if (((_direction == Direction.forward || _direction == Direction.forwardZeroCrossed) &&
              limitsReached == LimitReached.end) ||
          ((_direction == Direction.inReverse || _direction == Direction.reverseZeroCrossed) &&
              limitsReached == LimitReached.start)) {
        print('Not setting time from drag');
        return;
      }

      var _draggingTimeInMs = ((totalMs / kSweepAngle) * _timeRadians).toInt();
      print('Setting time from drag');
      tm.setTimeFromDrag(DraggingData(currentTimeInMs: _draggingTimeInMs, direction: _direction));
      _prevRadians = _timeRadians;
    } else {
      _prevRadians = _thumbRadians;
    }

    var _thumbCenterDx = _center.dx + (_progressLineRadius * cos(_thumbRadians));
    var _thumbCenterDy = _center.dy + (_progressLineRadius * sin(_thumbRadians));
    // print('ThumbX: $thumbCenterDx, ThumbY: $thumbCenterDy');

    paintProgressIndicatorCircleThumb(_progressColor, canvas, _thumbCenterDx, _thumbCenterDy, dragStarted);

    _hitPath = Path()
      ..addOval(
        Rect.fromCircle(
            //WARNING: hitTest path Offset does not take canvas translate and rotation
            //WARNING: into account
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
    return (currentMs != oldDelegate.currentMs) ||
        (dragStarted != oldDelegate.dragStarted) ||
        (dragPosition != oldDelegate.dragPosition);
  }

  // BUG: fix prevValue and currentValue issue after zeroCrossed
  Direction? checkDirection(double prevValue, double currentValue) {
    print('prevValue: $prevValue, currentValue: $currentValue, changingSession: ${ts.changingSession}');
    if (!ts.changingSession) {
      if (prevValue >= 6.0 && currentValue <= 1.0) return Direction.forwardZeroCrossed;
      if (prevValue <= 1.0 && currentValue >= 6.0) return Direction.reverseZeroCrossed;
    }

    if ((prevValue < currentValue) && (limitsReached != LimitReached.start)) {
      return Direction.forward;
    } else if ((prevValue > currentValue) && (limitsReached != LimitReached.end)) {
      return Direction.inReverse;
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

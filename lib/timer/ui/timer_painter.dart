import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_model/session.dart';
import 'package:pomodoro_timer/timer/_manager/timer_manager.dart';
import 'package:pomodoro_timer/timer/_models/dragging_data.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';
import 'package:pomodoro_timer/timer/ui/paint_objects.dart';

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
    var center = size.center(Offset.zero);
    var radius = min(size.width, size.height) / 2;
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var timerBkgRadius = radius - 20;
    var progressLineRadius = radius - 35;
    var centerCircleRadius = radius - 40;
    var progressColor = sessionType == SessionType.pomodoro //
        ? kPrimaryColor
        : kAlternateColor;
    limitsReached = tm.taskLimitsReached.value;

    // move 0 degree to top
    canvas.translate(centerX, centerY);
    canvas.rotate(1.5 * pi);
    canvas.translate(-centerX, -centerY);

    // Background layer
    paintBackground(canvas, center, radius);

    // Background progress indicator filler
    paintBackgroundProgressIndicator(center, timerBkgRadius, _currentAngle, canvas);

    // Progress Indicator line
    paintProgressIndicatorLine(center, progressLineRadius, progressColor, _currentAngle, canvas);

    // Center circle with glow shadow
    paintCenterCircleWithGlowShadow(progressColor, canvas, center, centerCircleRadius);

    //XXX Thumb @ Progress Indicator line pos XXX
    if (dragging) {
      var deltaX = (300 - dragPosition.dy) - center.dx;
      var deltaY = dragPosition.dx - center.dy;

      var dragRadians = atan2(deltaY, deltaX);
      print('totalMs: $totalMs, currentMs: $currentMs, limitsReached: $limitsReached');

      var timeRadians = convertToFullCircle(dragRadians);
      var direction = tm.checkDirection(_prevRadians, timeRadians);
      print('direction: $direction');

      if (direction == null) return;
      if (((direction == Direction.forward || direction == Direction.forwardZeroCrossed) &&
              limitsReached == LimitReached.end) ||
          ((direction == Direction.inReverse || direction == Direction.reverseZeroCrossed) &&
              limitsReached == LimitReached.start)) {
        print('Not setting time from drag');
        return;
      }

      var draggingTimeInMs = ((totalMs / kSweepAngle) * timeRadians).toInt();
      print('Setting time from drag');
      tm.setTimeFromDrag(DraggingData(currentTimeInMs: draggingTimeInMs, direction: direction));
      _prevRadians = timeRadians;
    } else {
      _prevRadians = _thumbRadians;
    }

    var thumbCenterDx = center.dx + (progressLineRadius * cos(_thumbRadians));
    var thumbCenterDy = center.dy + (progressLineRadius * sin(_thumbRadians));
    // print('ThumbX: $thumbCenterDx, ThumbY: $thumbCenterDy');

    paintProgressIndicatorCircleThumb(progressColor, canvas, thumbCenterDx, thumbCenterDy, dragStarted);

    _hitPath = Path()
      ..addOval(
        Rect.fromCircle(
            // hitTest path Offset does not take canvas translate and rotation into account!
            center: Offset(
              center.dx + (progressLineRadius) * sin(_thumbRadians),
              center.dy - (progressLineRadius) * cos(_thumbRadians),
            ),
            radius: 20),
      );
  }

  @override
  bool hitTest(Offset position) {
    var hit = _hitPath.contains(position);
    // print(hit);
    return hit;
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return (currentMs != oldDelegate.currentMs) ||
        (dragStarted != oldDelegate.dragStarted) ||
        (dragPosition != oldDelegate.dragPosition);
  }

  double convertToFullCircle(double radians) => //
      radians < 0 ? (2 * pi) + radians : radians;

  double convertToHalfCircle(double radians) => //
      radians > pi ? (pi - radians) : radians;
}

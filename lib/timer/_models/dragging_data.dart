import 'package:pomodoro_timer/constants.dart';

/// Data from dragging timer thumb that includes conversion of coords to time in
/// milliseconds and Direction value.
class DraggingData {
  final int currentTimeInMs;
  final Direction? direction;

  DraggingData({
    required this.currentTimeInMs,
    required this.direction,
  });
}

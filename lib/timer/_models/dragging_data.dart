import 'package:pomodoro_timer/timer/widgets/timer_painter.dart';

/// Data from dragging timer thumb that includes conversion of coords to time in
/// milliseconds and Momentum value.
class DraggingData {
  final int currentTimeInMs;
  final Momentum? momentum;

  DraggingData({
    required this.currentTimeInMs,
    required this.momentum,
  });
}

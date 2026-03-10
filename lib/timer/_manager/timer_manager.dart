import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
import 'package:pomodoro_timer/timer/_models/dragging_data.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';

class TimerManager {
  TimerService tms = GetIt.I<TimerService>();
  TasksService tks = GetIt.I<TasksService>();
  TasksManager tkm = GetIt.I<TasksManager>();

  final Signal<bool> dragStarted = signal(false);
  final Signal<Offset> updateDragPosition = signal(Offset.zero);
  final Signal<bool> dragging = signal(false);
  final Signal<LimitReached> taskLimitsReached = signal(LimitReached.none);
  bool _changingSession = false;

  late final Computed<Duration> getCurrentTime = computed(() => tms.currentTime.value);

  TimerManager() {
    effect(() {
      final currentTime = tms.currentTime.value;
      if (tks.sessions.value.isNotEmpty && tks.sessions.value.length > tks.currentSessionIndex.value) {
        if (currentTime >= tks.currentSession.duration && !dragging.peek()) {
          nextSession();
        }
      }
    });

    initTimer();
  }

  void initTimer() {
    tms.init();
  }

  void startTimer() {
    tms.start();
    print('timer started');
  }

  void stopTimer() {
    tms.pause();
    print('timer stopped');
  }

  void resetTimer() {
    print('Resetting timer');
    tms.resetTimerToZero();
  }

  void cancelTimer() {
    print('Cancelling timer');
    tms.cancelTimer();
  }

  void setDragStartedState(bool dragStart) {
    tms.setDragStartedState(dragStarted: dragStart);
    dragStarted.value = dragStart;
    if (!dragStart) {
      dragging.value = false;
    }
  }

  void setDragPosition(Offset position) {
    updateDragPosition.value = position;
    dragging.value = true;
  }

  void nextSession() {
    tkm.sessionEnded();

    if (tkm.taskIsDone.value) {
      cancelTimer();
    } else {
      resetTimer();
    }
  }

  void setTimeFromDrag(DraggingData draggingData) {
    if (draggingData.direction == null) {
      print('Direction is null. Returning from setTimeFromDrag');
      return;
    }
    
    var timeToBeSet = draggingData.currentTimeInMs;
    if (tks.sessions.value.isEmpty || tks.sessions.value.length <= tks.currentSessionIndex.value) return;
    var totalTimeinMs = tks.currentSession.duration.inMilliseconds;

    if (draggingData.direction == Direction.forwardZeroCrossed) {
      if (taskLimitsReached.value == LimitReached.end) return;

      if (tks.lastSession.value || tkm.taskIsDone.value) {
        timeToBeSet = totalTimeinMs;

        tms.changeSession(SessionChange.end);
        tms.setTimeFromMilliseconds(timeToBeSet);

        taskLimitsReached.value = LimitReached.end;
      } else {
        taskLimitsReached.value = LimitReached.none;

        _changingSession = true;
        tms.changeSession(SessionChange.forward);
        
        // Ratio of overshoot
        double overflowRatio = draggingData.currentTimeInMs / totalTimeinMs;
        int newTotal = tks.currentSession.duration.inMilliseconds;
        timeToBeSet = (newTotal * overflowRatio).toInt().clamp(0, newTotal);
        
        tms.setTimeFromMilliseconds(timeToBeSet);
        tms.updateCurrentTime(Duration(milliseconds: timeToBeSet));
        _changingSession = false;
      }

      return;
    }

    if (draggingData.direction == Direction.reverseZeroCrossed) {
      if (taskLimitsReached.value == LimitReached.start) return;
      print('Backwards: Current session: ${tks.currentSessionIndex.value}');

      if (tks.currentSessionIndex.value == 0) {
        print(
            'Absolute zero. draggingData.currentTimeInMs: ${draggingData.currentTimeInMs}');

        tms.changeSession(SessionChange.beginning);
        taskLimitsReached.value = LimitReached.start;
        timeToBeSet = 0;
      } else {
        taskLimitsReached.value = LimitReached.none;
        
        _changingSession = true;
        tms.changeSession(SessionChange.backward);
        
        // Ratio of undershoot
        double remainingRatio = draggingData.currentTimeInMs / totalTimeinMs;
        int newTotal = tks.currentSession.duration.inMilliseconds;
        timeToBeSet = (newTotal * remainingRatio).toInt().clamp(0, newTotal);

        tms.setTimeFromMilliseconds(timeToBeSet);
        tms.updateCurrentTime(Duration(milliseconds: timeToBeSet));
        _changingSession = false;
      }
      return;
    }

    if (draggingData.direction == Direction.forward ||
        draggingData.direction == Direction.inReverse) {
      taskLimitsReached.value = LimitReached.none;
    }

    if (taskLimitsReached.value == LimitReached.none) {
      tms.setTimeFromMilliseconds(timeToBeSet);
    }
  }

  Direction? checkDirection(double prevValue, double currentValue) {
    print(
        'prevValue: $prevValue, currentValue: $currentValue, changingSession: $_changingSession');
    if (!_changingSession) {
      if (prevValue >= 6.0 && currentValue <= 1.0) {
        return Direction.forwardZeroCrossed;
      }
      if (prevValue <= 1.0 && currentValue >= 6.0) {
        return Direction.reverseZeroCrossed;
      }
    }

    if ((prevValue < currentValue) &&
        (taskLimitsReached.value != LimitReached.start)) {
      return Direction.forward;
    } else if ((prevValue > currentValue) &&
        (taskLimitsReached.value != LimitReached.end)) {
      return Direction.inReverse;
    }
    return null;
  }
}

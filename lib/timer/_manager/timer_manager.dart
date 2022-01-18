import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
import 'package:pomodoro_timer/timer/_models/dragging_data.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';

class TimerManager {
  late Command<void, bool> initTimer;
  late Command<void, Duration> getCurrentTime;
  late Command<DraggingData, void> setTimeFromDrag;
  late Command<void, void> startTimer;
  late Command<void, void> stopTimer;
  late Command<void, void> resetTimer;
  late Command<void, void> cancelTimer;
  late Command<bool, bool> dragStarted;
  late Command<Offset, Offset> updateDragPosition;
  late Command<bool, bool> dragging;
  late Command<LimitReached, LimitReached> taskLimitsReached;

  TimerService tms = GetIt.I<TimerService>();
  TasksService tks = GetIt.I<TasksService>();
  TasksManager tkm = GetIt.I<TasksManager>();
  // bool _timerStartReached = false;
  // bool _timerEndReached = false;

  TimerManager() {
    tms.currentTime.listen((currentTime, _) {
      if ((currentTime >= tks.currentSession.duration) && !dragging.value) {
        nextSession();
      }
      getCurrentTime();
    });

    initTimer = Command.createSyncNoParam<bool>(
      tms.init,
      false,
    );

    startTimer = Command.createSyncNoParamNoResult(
      () {
        tms.start();
        print('timer started');
      },
    );

    stopTimer = Command.createSyncNoParamNoResult(
      () {
        tms.pause();
        print('timer stopped');
      },
    );

    resetTimer = Command.createSyncNoParamNoResult(() {
      print('Resetting timer');
      tms.resetTimerToZero();
    });

    cancelTimer = Command.createSyncNoParamNoResult(() {
      print('Cancelling timer');
      tms.cancelTimer();
    });

    getCurrentTime = Command.createSyncNoParam<Duration>(
      () => tms.currentTime.value,
      Duration.zero,
    );

    setTimeFromDrag = Command.createSyncNoResult(
      (DraggingData draggingData) {
        if (draggingData.direction == null) {
          print('Direction is null. Returning from setTimeFromDrag');
          return;
        }
        var _timeToBeSet = draggingData.currentTimeInMs;
        var totalTimeinMs = tks.currentSession.duration.inMilliseconds;

        if (draggingData.direction == Direction.forwardZeroCrossed) {
          if (taskLimitsReached.value == LimitReached.end) return;

          if (tks.lastSession || tkm.taskIsDone.value) {
            // _timerEndReached = true;
            _timeToBeSet = totalTimeinMs;

            tms.setSessionChangeFlag(status: SessionChange.end);
            tms.setTimeFromMilliseconds(_timeToBeSet);

            taskLimitsReached(LimitReached.end);
          } else {
            // _timerEndReached = false;
            taskLimitsReached(LimitReached.none);

            tms.setSessionChangeFlag(status: SessionChange.forward);
            _timeToBeSet = draggingData.currentTimeInMs;
          }

          return;
        }

        if (draggingData.direction == Direction.reverseZeroCrossed) {
          if (taskLimitsReached.value == LimitReached.start) return;
          print('Backwards: Current session: ${tks.currentSessionIndex.value}');

          if (tks.currentSessionIndex.value == 0) {
            print('Absolute zero. draggingData.currentTimeInMs: ${draggingData.currentTimeInMs}');

            // _timerStartReached = true;
            tms.setSessionChangeFlag(status: SessionChange.beginning);
            taskLimitsReached(LimitReached.start);
            _timeToBeSet = 0;
          } else {
            // _timerStartReached = false;
            taskLimitsReached(LimitReached.none);
            tms.setTimeFromMilliseconds(_timeToBeSet);
            tms.setSessionChangeFlag(status: SessionChange.backward);
            // _timeToBeSet = tks.currentSession.duration.inMilliseconds - 1000;
          }
        }

        if (draggingData.direction == Direction.forward || draggingData.direction == Direction.inReverse) {
          taskLimitsReached(LimitReached.none);
        }

        if (taskLimitsReached.value == LimitReached.none) tms.setTimeFromMilliseconds(_timeToBeSet);
        tms.changingSession = false;
      },
    );

    dragStarted = Command.createSync((dragStart) {
      tms.setDragStartedState(dragStarted: dragStart);
      if (!dragStart) {
        dragging(false);
      }

      return dragStart;
    }, false);

    updateDragPosition = Command.createSync((position) {
      dragging(true);
      return position;
    }, Offset.zero);

    dragging = Command.createSync((status) => status, false);

    taskLimitsReached = Command.createSync((status) {
      print('taskLimitsReached: $status');
      return status;
    }, LimitReached.none);

    initTimer();
  }

  void nextSession() {
    tkm.sessionEnded();

    if (tkm.taskIsDone.value) {
      cancelTimer();
    } else {
      resetTimer();
    }
  }

  // Calculate dragging direction and position of thumb relative to 0.00
  // BUG: fix prevValue and currentValue issue after zeroCrossed
  Direction? checkDirection(double prevValue, double currentValue) {
    print('prevValue: $prevValue, currentValue: $currentValue, changingSession: ${tms.changingSession}');
    if (!tms.changingSession) {
      if (prevValue >= 6.0 && currentValue <= 1.0) return Direction.forwardZeroCrossed;
      if (prevValue <= 1.0 && currentValue >= 6.0) return Direction.reverseZeroCrossed;
    }

    if ((prevValue < currentValue) && (taskLimitsReached.value != LimitReached.start)) {
      return Direction.forward;
    } else if ((prevValue > currentValue) && (taskLimitsReached.value != LimitReached.end)) {
      return Direction.inReverse;
    }
  }
}

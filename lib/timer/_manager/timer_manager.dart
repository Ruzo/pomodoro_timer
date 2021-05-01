import 'package:flutter/gestures.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';

class TimerManager {
  late Command<void, bool> initTimer;
  late Command<void, Duration> getCurrentTime;
  late Command<Duration, void> setCurrentTime;
  late Command<void, void> startAtCurrentTime;
  late Command<void, void> startTimer;
  late Command<void, void> stopTimer;
  late Command<void, void> resetTimer;
  late Command<void, void> cancelTimer;
  late Command<bool, bool> dragStarted;
  late Command<Offset, Offset> updateDragPosition;

  var tms = GetIt.I<TimerService>();
  var tks = GetIt.I<TasksService>();
  var tkm = GetIt.I<TasksManager>();

  TimerManager() {
    // restart or cancel timer when session total time is reached
    tms.currentTime.listen((currentTime, _) {
      if (currentTime >= tks.currentSession.duration) {
        tkm.sessionEnded();
        if (tkm.taskIsDone.value)
          cancelTimer();
        else
          resetTimer();
      }
    });

    // Start periodic timer to update currentTime with Stopwatch elapsed time.
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

    setCurrentTime = Command.createSyncNoResult(
      (time) {
        tms.setCurrentTime(time);
      },
    );

    startAtCurrentTime = Command.createSyncNoParamNoResult(
      () {
        tms.startAtCurrentTime();
      },
    );

    dragStarted = Command.createSync((b) {
      print('dragStarted Command: $b');
      return b;
    }, false);

    updateDragPosition = Command.createSync((position) {
      return position;
    }, Offset.zero);

    initTimer();
  }
}

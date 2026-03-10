import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';

enum SessionChange { none, forward, backward, end, beginning }

class TimerService {
  Ticker _ticker = Ticker((_) {});
  DateTime _timeAtZero = DateTime.now();
  Duration _dragTime = Duration.zero;
  bool _isDragging = false;

  final Signal<Duration> currentTime = signal(Duration.zero);
  final Signal<double> percentageDone = signal(0.0);
  final Signal<bool> timerIsRunning = signal(false);

  bool get timerIsTicking => _ticker.isTicking;

  final _ts = GetIt.I<TasksService>();
  final _tm = GetIt.I<TasksManager>();

  bool init() {
    _ticker.stop();
    timerIsRunning.value = false;
    currentTime.value = Duration.zero;

    if (!_ticker.isTicking) {
      _ticker = Ticker((_) {
        var timeToUpdateTo = _isDragging //
            ? _dragTime
            : DateTime.now().difference(_timeAtZero);

        updateCurrentTime(timeToUpdateTo);
      });
    }

    print('timer init');
    return _ticker.isActive;
  }

  void updateCurrentTime([Duration newTime = Duration.zero]) {
    currentTime.value = newTime;
    if (_ts.sessions.value.isNotEmpty && _ts.sessions.value.length > _ts.currentSessionIndex.value) {
      percentageDone.value = currentTime.value.inMilliseconds / _ts.currentSession.duration.inMilliseconds;
    } else {
      percentageDone.value = 0.0;
    }
  }

  void start() {
    _timeAtZero = DateTime.now().subtract(currentTime.value);
    _ticker.start();
    timerIsRunning.value = _ticker.isActive;
  }

  void pause() {
    _ticker.stop();
    timerIsRunning.value = _ticker.isActive;
  }

  void resetTimerToZero() {
    _ticker.muted = true;
    currentTime.value = Duration.zero;
    _timeAtZero = DateTime.now();
    _ticker.muted = false;
    timerIsRunning.value = _ticker.isActive;
  }

  void cancelTimer() {
    _ticker.stop();
    currentTime.value = _ts.currentSession.duration;
    timerIsRunning.value = false;
  }

  void setTimeFromMilliseconds(int timeInMs) {
    _dragTime = Duration(milliseconds: timeInMs);
  }

  void setDragStartedState({required bool dragStarted}) {
    if (dragStarted) {
      _dragTime = currentTime.value;
      _isDragging = dragStarted;
      if (!_ticker.isActive) _ticker.start();
      return;
    }
    if (!dragStarted) {
      _timeAtZero = DateTime.now().subtract(currentTime.value);
      _isDragging = dragStarted;
      _dragTime = Duration.zero;
      if (!timerIsRunning.value) _ticker.stop();
    }
  }

  void changeSession(SessionChange sessionChange) {
    switch (sessionChange) {
      case SessionChange.forward:
        _tm.sessionEnded();
        currentTime.value = Duration.zero;
        break;

      case SessionChange.backward:
        print('Session backward');
        _tm.loadPrevSession();
        break;

      case SessionChange.end:
        print('Session end');
        _tm.sessionEnded();
        cancelTimer();
        break;

      case SessionChange.beginning:
        print('Session beginning');
        _ticker.stop();
        currentTime.value = Duration.zero;
        timerIsRunning.value = false;
        break;

      default:
    }
  }
}


import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';

enum SessionChange { none, forward, backward, end, beginning }

class TimerService {
  Ticker _ticker = Ticker((_) {});
  DateTime _timeAtZero = DateTime.now();
  Duration _dragTime = Duration.zero;
  bool _isDragging = false;
  SessionChange _scheduleSessionChange = SessionChange.none;
  bool changingSession = false;

  final ValueNotifier<Duration> _currentTime = ValueNotifier<Duration>(Duration.zero);
  ValueNotifier<Duration> get currentTime => _currentTime;

  final ValueNotifier<double> _percentageDone = ValueNotifier<double>(0.0);
  ValueNotifier<double> get percentageDone => _percentageDone;

  final ValueNotifier<bool> _timerIsRunning = ValueNotifier<bool>(false);
  ValueNotifier<bool> get timerIsRunning => _timerIsRunning;

  bool get timerIsTicking => _ticker.isTicking;

  void setSessionChangeFlag({required SessionChange status}) => _scheduleSessionChange = status;

  final _ts = GetIt.I<TasksService>();
  final _tm = GetIt.I<TasksManager>();

  bool init() {
    _ticker.stop();
    _timerIsRunning.value = false;
    _currentTime.value = Duration.zero;

    if (!_ticker.isTicking) {
      _ticker = Ticker((_) {
        if (_scheduleSessionChange != SessionChange.none) return changeSession(_scheduleSessionChange);

        var _timeToUpdateTo = _isDragging //
            ? _dragTime
            : DateTime.now().difference(_timeAtZero);

        updateCurrentTime(_timeToUpdateTo);
      });
    }

    print('timer init');
    return _ticker.isActive;
  }

  void updateCurrentTime([Duration newTime = Duration.zero]) {
    _currentTime.value = newTime;
    _percentageDone.value = _currentTime.value.inMilliseconds / _ts.currentSession.duration.inMilliseconds;
  }

  void start() {
    _timeAtZero = DateTime.now().subtract(currentTime.value);
    _ticker.start();
    _timerIsRunning.value = _ticker.isActive;
  }

  void pause() {
    _ticker.stop();
    _timerIsRunning.value = _ticker.isActive;
  }

  void resetTimerToZero() {
    _ticker.muted = true;
    _currentTime.value = Duration.zero;
    _timeAtZero = DateTime.now();
    _ticker.muted = false;
    _timerIsRunning.value = _ticker.isActive;
  }

  void cancelTimer() {
    _ticker.stop();
    _currentTime.value = _ts.currentSession.duration;
    _timerIsRunning.value = false;
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
      if (!_timerIsRunning.value) _ticker.stop();
    }
  }

  void changeSession(SessionChange sessionChange) {
    setSessionChangeFlag(status: SessionChange.none);
    changingSession = true;
    print('changingSession');

    switch (sessionChange) {
      case SessionChange.forward:
        _tm.sessionEnded();
        _currentTime.value = Duration.zero;
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
        _currentTime.value = Duration.zero;
        _timerIsRunning.value = false;
        break;

      default:
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';

class TimerService {
  Ticker _ticker = Ticker((_) {});
  DateTime _pauseTime = DateTime.now();
  DateTime _timeAtZero = DateTime.now();
  bool _paused = false;
  Duration _timeOffset = Duration.zero;

  ValueNotifier<Duration> _currentTime = ValueNotifier<Duration>(Duration.zero);
  ValueNotifier<Duration> get currentTime => _currentTime;

  ValueNotifier<double> _percentageDone = ValueNotifier<double>(0.0);
  ValueNotifier<double> get percentageDone => _percentageDone;

  ValueNotifier<bool> _timerIsRunning = ValueNotifier<bool>(false);
  ValueNotifier<bool> get timerIsRunning => _timerIsRunning;

  bool get timerIsTicking => _ticker.isTicking;

  var ts = GetIt.I<TasksService>();

  void setCurrentTime(Duration newTime) {
    _currentTime.value = newTime;
  }

  bool init() {
    _ticker.stop();
    _timeOffset = Duration.zero;
    _paused = false;
    _timerIsRunning.value = false;
    _currentTime.value = Duration.zero;
    if (!_ticker.isTicking) {
      _ticker = Ticker((_) {
        updateCurrentTime();
      });
    }

    print('timer init');
    return _ticker.isActive;
  }

  void updateCurrentTime() {
    _currentTime.value = DateTime.now().subtract(_timeOffset).difference(_timeAtZero);
    _percentageDone.value = _currentTime.value.inMilliseconds / ts.currentSession.duration.inMilliseconds;
  }

  void start() {
    if (!_paused) _timeAtZero = DateTime.now();
    _timeOffset += _paused ? DateTime.now().difference(_pauseTime) : Duration.zero;
    _ticker.start();
    _timerIsRunning.value = _ticker.isActive;
  }

  void pause() {
    _ticker.stop();
    _pauseTime = DateTime.now();
    _paused = true;
    print(_pauseTime);
    _timerIsRunning.value = _ticker.isActive;
  }

  void resetTimerToZero() {
    _ticker.muted = true;
    _timeOffset = Duration.zero;
    _paused = false;
    _currentTime.value = Duration.zero;
    _timeAtZero = DateTime.now();
    _ticker.muted = false;
    _timerIsRunning.value = _ticker.isActive;
  }

  void cancelTimer() {
    _ticker.stop();
    _timeOffset = Duration.zero;
    _paused = false;
    _currentTime.value = Duration.zero;
    _timerIsRunning.value = false;
  }

  void startAtCurrentTime() {
    // _stopwatch.reset();
    // _offsetInMs = _currentTime.value.inMilliseconds;
    // _stopwatch.start();
  }
}

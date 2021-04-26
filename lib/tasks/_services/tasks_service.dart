import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_model/Session.dart';
import 'package:pomodoro_timer/tasks/_model/task.dart';
import 'package:pomodoro_timer/tasks/_services/mock_data.dart';

class TasksService extends ChangeNotifier {
  MockData _data = MockData();
  List<Task> _tasksList = [];
  Task _selectedTask = Task();
  List<Session> _sessions = [];
  bool _lastSession = false;

  TasksService();

  ValueNotifier<int> _currentSessionIndex = ValueNotifier<int>(0);
  ValueNotifier<int> get currentSessionIndex => _currentSessionIndex;
  Session get currentSession => _sessions[_currentSessionIndex.value];

  ValueNotifier<bool> _dataIsInitialized = ValueNotifier<bool>(false);
  ValueNotifier<bool> get dataIsInitialized => _dataIsInitialized;

  ValueNotifier<bool> _taskIsDone = ValueNotifier<bool>(false);
  ValueNotifier<bool> get taskIsDone => _taskIsDone;
  ValueNotifier<bool> get disableStart => ValueNotifier<bool>(!_taskIsDone.value);

  Task get selectedTask => _selectedTask;
  List<Session> get sessions => _sessions;
  Task get defaultTask => Task().defaultTimer();
  bool get lastSession => _lastSession;

  void selectNewTask(Task task) => _selectedTask = task;

  Future<bool> init() async {
    print('Init Task');
    _tasksList = await data;
    _selectedTask = _tasksList[0];
    _sessions = _generateSessions(_selectedTask);
    _currentSessionIndex.value = 0;
    _dataIsInitialized.value = true;
    return _dataIsInitialized.value;
  }

  Future<List<Task>> get data => Future.delayed(
        Duration(
          seconds: Random().nextInt(3),
        ),
        () => _data.tasksList,
      );

  Future<Task> taskById(String? id) => Future.delayed(
        Duration(
          seconds: Random().nextInt(3),
        ),
        () {
          print('getting taskById');
          if (id == null) throw 'Task not found!';
          Task _task = (id == '')
              ? defaultTask
              : _data.tasksList.firstWhere(
                  (task) => (task.id == id),
                );
          return _task;
        },
      );

  bool nextSession() {
    _sessions[_currentSessionIndex.value].done = true;
    if (_lastSession) {
      _taskIsDone.value = true;
      _currentSessionIndex.notifyListeners();
      return _taskIsDone.value;
    }
    _currentSessionIndex.value += 1;
    if (_currentSessionIndex.value == _sessions.length - 1) _lastSession = true;
    // print(_lastSession);
    return _taskIsDone.value;
  }

  List<Session> _generateSessions(Task task) {
    // print('Generating sessions');
    List<Session> _sessionsList = [];
    for (int i = 0; i < task.pomodoros.length; i++) {
      int _lastPomodoro = task.pomodoros.length - 1;
      _sessionsList.add(
        Session(
          duration: task.pomodoros[i].duration,
          type: SessionType.pomodoro,
        ),
      );
      if (i != _lastPomodoro) {
        i == task.longBreakInterval - 1
            ? _sessionsList.add(
                Session(
                  duration: task.longBreak,
                  type: SessionType.long_break,
                ),
              )
            : _sessionsList.add(
                Session(
                  duration: task.shortBreak,
                  type: SessionType.short_break,
                ),
              );
      }
    }
    return _sessionsList;
  }
}

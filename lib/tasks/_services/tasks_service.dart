import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_timer/tasks/_model/session.dart';
import 'package:pomodoro_timer/tasks/_model/task.dart';
import 'package:pomodoro_timer/tasks/_services/mock_data.dart';

class TasksService {
  final MockData _data = MockData();
  List<Task> _tasksList = [];
  List<Session> _sessions = [];
  Task selectedTask = Task();
  bool lastSession = false;

  final ValueNotifier<int> _currentSessionIndex = ValueNotifier<int>(0);
  ValueNotifier<int> get currentSessionIndex => _currentSessionIndex;

  Session get currentSession => _sessions[_currentSessionIndex.value];

  void setCurrentSessionIndex(int index) => _currentSessionIndex.value = index;

  void setSessionAsDone(int index) => _sessions[index] = _sessions[index].copyWith(done: true);
  void undoSession(int index) => _sessions[index] = _sessions[index].copyWith(done: false);

  List<Session> get sessions => _sessions;

  Task get defaultTask => Task().defaultTimer();

  List<Task> get taskList => _tasksList;

  Future<Task> init() async {
    print('Init Task');
    var clientData = await data;
    _tasksList = clientData.tasksList;
    var _selectedTask = await taskById(clientData.selectedTaskID);
    _sessions = _selectedTask.sessions;
    _currentSessionIndex.value = _selectedTask.currentSession;
    return _selectedTask;
  }

  Future<MockData> get data => Future.delayed(
        Duration(
          seconds: Random().nextInt(3),
        ),
        () => _data,
      );

  Future<Task> taskById(String? id) => Future.delayed(
        Duration(
          seconds: Random().nextInt(3),
        ),
        () {
          print('getting taskById');
          if (id == null) throw 'Task not found!';
          var _task = (id == '')
              ? defaultTask
              : _data.tasksList.firstWhere(
                  (task) => (task.id == id),
                );
          return _task;
        },
      );
}

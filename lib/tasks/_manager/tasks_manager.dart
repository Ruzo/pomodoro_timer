import 'package:flutter/cupertino.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/tasks/_model/task.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';

class TasksManager extends ChangeNotifier {
  late Command<void, void> initData;
  late Command<void, Task> getCurrentTask;
  late Command<Task, void> setCurrentTask;
  late Command<String, Task> getTaskById;
  late Command<void, List<Task>> getTasksList;
  late Command<void, bool> sessionEnded;
  late Command<bool, bool> dataIsInitialized;
  late Command<bool, bool> taskIsDone;

  Task _selectedTask = Task();
  bool _lastSession = false;

  TasksManager() {
    var ts = GetIt.I<TasksService>();

    initData = Command.createAsyncNoParamNoResult(() async {
      print('Init Task');
      _selectedTask = await ts.init();
      if (ts.currentSessionIndex.value == _selectedTask.sessions.length - 1) _lastSession = true;
      dataIsInitialized(true);
    });

    getCurrentTask = Command.createAsyncNoParam<Task>(() async {
      return _selectedTask;
    }, ts.defaultTask);

    setCurrentTask = Command.createSyncNoResult((task) => _selectedTask = task);

    getTaskById = Command.createAsync((id) => ts.taskById(id), Task());

    getTasksList = Command.createSyncNoParam(() => ts.taskList, []);

    getTaskById.thrownExceptions.listen((ex, _) => print('${ex?.error}'));

    sessionEnded = Command.createSyncNoParam(() {
      if (!taskIsDone.value) {
        ts.setSessionAsDone(ts.currentSessionIndex.value);
        if (_lastSession) {
          taskIsDone(true);
          ts.currentSessionIndex.notifyListeners();
          return true;
        }
        ts.setCurrentSessionIndex(ts.currentSessionIndex.value + 1);
        if (ts.currentSessionIndex.value == _selectedTask.sessions.length - 1) _lastSession = true;
      }
      return false;
    }, false);

    dataIsInitialized = Command.createSync((b) => b, false);

    taskIsDone = Command.createSync((b) => b, false);

    initData();
  }
}

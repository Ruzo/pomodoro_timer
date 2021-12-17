import 'package:flutter/cupertino.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/tasks/_model/task.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';

class TasksManager extends ChangeNotifier {
  late Command<void, bool> initData;
  late Command<void, Task> getCurrentTask;
  late Command<Task, void> setCurrentTask;
  late Command<String, Task> getTaskById;
  late Command<void, List<Task>> getTasksList;
  late Command<void, bool> sessionEnded;
  late Command<void, void> loadPrevSession;
  late Command<bool, bool> dataIsInitialized;
  late Command<bool, bool> taskIsDone;

  TasksManager() {
    var ts = GetIt.I<TasksService>();

    initData = Command.createAsyncNoParam(() async {
      if (dataIsInitialized.value) return true;
      print('Init Task Manager');

      ts.selectedTask = await ts.init();

      if (ts.currentSessionIndex.value == ts.selectedTask.sessions.length - 1) ts.lastSession = true;

      getCurrentTask();
      dataIsInitialized(true);

      return dataIsInitialized.value;
    }, false);

    getCurrentTask = Command.createSyncNoParam<Task>(() {
      return ts.selectedTask;
    }, ts.defaultTask);

    setCurrentTask = Command.createSyncNoResult((task) {
      ts.selectedTask = task;
      getCurrentTask();
    });

    getTaskById = Command.createAsync((id) => ts.taskById(id), Task());

    getTasksList = Command.createSyncNoParam(() => ts.taskList, []);

    getTaskById.thrownExceptions.listen((ex, _) => print('${ex?.error}'));

    sessionEnded = Command.createSyncNoParam(() {
      if (!taskIsDone.value) {
        ts.setSessionAsDone(ts.currentSessionIndex.value);
        if (ts.lastSession) {
          taskIsDone(true);
          ts.currentSessionIndex.notifyListeners();
          return true;
        }
        ts.setCurrentSessionIndex(ts.currentSessionIndex.value + 1);
        if (ts.currentSessionIndex.value == ts.selectedTask.sessions.length - 1) ts.lastSession = true;
      }
      return false;
    }, false);

    loadPrevSession = Command.createSyncNoParamNoResult(() {
      if (ts.currentSessionIndex.value != 0) {
        ts.setCurrentSessionIndex(ts.currentSessionIndex.value - 1);
        ts.undoSession(ts.currentSessionIndex.value);
        taskIsDone(false);
        ts.lastSession = false;
        return;
      }
      print('Skipping loadPreviousSession');
    });

    dataIsInitialized = Command.createSync((b) => b, false);

    taskIsDone = Command.createSync((b) => b, false);

    initData();
  }
}

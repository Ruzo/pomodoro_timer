import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/tasks/_model/task.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
// import 'package:pomodoro_timer/timer/_manager/timer_manager.dart';
// import 'package:pomodoro_timer/timer/_services/timer_service.dart';

class TasksManager {
  late Command<void, bool> initData;
  late Command<void, Task> getCurrentTask;
  late Command<Task, void> setCurrentTask;
  late Command<String, Task> getTaskById;
  late Command<void, List<Task>> getTasksList;
  late Command<void, bool> sessionEnded;

  // var ts = GetIt.I<TasksService>();
  // var tms = GetIt.I<TimerService>();
  // var tmm = GetIt.I<TimerManager>();

  TasksManager() {
    var ts = GetIt.I<TasksService>();
    // var tms = GetIt.I<TimerService>();
    // var tmm = GetIt.I<TimerManager>();
    initData = Command.createAsyncNoParam(() => ts.init(), false);

    getCurrentTask = Command.createAsyncNoParam<Task>(() async {
      if (!ts.dataIsInitialized.value) await ts.init();
      return ts.selectedTask;
    }, ts.defaultTask);

    setCurrentTask = Command.createSyncNoResult((task) => ts.selectNewTask(task));

    getTaskById = Command.createAsync((id) => ts.taskById(id), Task());

    getTasksList = Command.createAsyncNoParam(() => ts.data, []);

    getTaskById.thrownExceptions.listen((ex, _) => print('${ex?.error}'));

    sessionEnded = Command.createSyncNoParam(() {
      if (!ts.taskIsDone.value) {
        bool _taskIsDone = ts.nextSession();
        if (_taskIsDone) return true;
        // tms.reset();
        // tms.start();
      }
      return false;
    }, false);

    initData();

    // tms.endOfSession.listen((endOfSession, _) {
    //   if (endOfSession) sessionEnded();
    // });
  }
}

import 'package:signals_flutter/signals_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/tasks/_model/task.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';

class TasksManager {
  final Signal<bool> dataIsInitialized = signal(false);
  final Signal<bool> taskIsDone = signal(false);

  final ts = GetIt.I<TasksService>();

  late final Computed<Task> getCurrentTask = computed(() => ts.selectedTask.value);
  late final Computed<List<Task>> getTasksList = computed(() => ts.taskList.value);

  TasksManager() {
    initData();
  }

  Future<bool> initData() async {
    if (dataIsInitialized.value) return true;
    print('Init Task Manager');

    ts.selectedTask.value = await ts.init();

    if (ts.currentSessionIndex.value == ts.selectedTask.value.sessions.length - 1) {
      ts.lastSession.value = true;
    }

    dataIsInitialized.value = true;
    return dataIsInitialized.value;
  }

  void setCurrentTask(Task task) {
    ts.selectedTask.value = task;
  }

  Future<Task> getTaskById(String? id) => ts.taskById(id);

  bool sessionEnded() {
    if (!taskIsDone.value) {
      ts.setSessionAsDone(ts.currentSessionIndex.value);
      if (ts.lastSession.value) {
        taskIsDone.value = true;
        return true;
      }
      ts.setCurrentSessionIndex(ts.currentSessionIndex.value + 1);
      if (ts.currentSessionIndex.value == ts.selectedTask.value.sessions.length - 1) {
        ts.lastSession.value = true;
      }
    }
    return false;
  }

  void loadPrevSession() {
    if (ts.currentSessionIndex.value != 0) {
      ts.setCurrentSessionIndex(ts.currentSessionIndex.value - 1);
      ts.undoSession(ts.currentSessionIndex.value);
      taskIsDone.value = false;
      ts.lastSession.value = false;
      return;
    }
    print('Skipping loadPreviousSession');
  }
}


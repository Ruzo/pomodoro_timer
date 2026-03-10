import 'dart:math';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:pomodoro_timer/tasks/_model/session.dart';
import 'package:pomodoro_timer/tasks/_model/task.dart';
import 'package:pomodoro_timer/tasks/_services/mock_data.dart';

class TasksService {
  final MockData _data = MockData();
  final Signal<List<Task>> taskList = signal([]);
  final Signal<List<Session>> sessions = signal([]);
  final Signal<Task> selectedTask = signal(Task().defaultTimer());
  final Signal<bool> lastSession = signal(false);

  final Signal<int> currentSessionIndex = signal(0);

  Session get currentSession => sessions.value[currentSessionIndex.value];

  void setCurrentSessionIndex(int index) => currentSessionIndex.value = index;

  void setSessionAsDone(int index) {
    final s = List<Session>.from(sessions.value);
    s[index] = s[index].copyWith(done: true);
    sessions.value = s;
  }

  void undoSession(int index) {
    final s = List<Session>.from(sessions.value);
    s[index] = s[index].copyWith(done: false);
    sessions.value = s;
  }

  Task get defaultTask => Task().defaultTimer();

  void removeTask(String id) {
    var task = taskList.value.firstWhere((t) => t.id == id);
    taskList.value = List.from(taskList.value)..remove(task);
  }

  void setSelectedTask(Task task) {
    if (selectedTask.value.id == task.id) return;
    selectedTask.value = task;
  }

  Future<Task> init() async {
    print('Init Task Service');
    var clientData = await data;
    taskList.value = clientData.tasksList;
    var fetchedTask = await taskById(clientData.selectedTaskID);
    sessions.value = fetchedTask.sessions;
    currentSessionIndex.value = fetchedTask.currentSession;
    return fetchedTask;
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
          assert(id != null);
          var task = (id == '')
              ? defaultTask
              : _data.tasksList.firstWhere(
                  (task) => (task.id == id),
                );
          return task;
        },
      );
}

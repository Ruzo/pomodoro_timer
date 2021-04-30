import 'package:pomodoro_timer/tasks/_model/pomodoro.dart';
import 'package:pomodoro_timer/tasks/_model/task.dart';

class MockData {
  List<Task> tasksList;
  String selectedTaskID = '';

  MockData()
      : tasksList = [
          Task(
            title: 'Default Pomodoro timer',
            pomodoros: const [
              Pomodoro(),
              Pomodoro(),
              // Pomodoro(),
              // Pomodoro(),
              // Pomodoro(),
            ],
            shortBreak: const Duration(minutes: 1),
            longBreak: const Duration(minutes: 2),
          ),
          Task(title: 'Work on Pomodoro timer'),
          Task(title: 'Write about learning experience'),
        ] {
    selectedTaskID = tasksList[0].id;
  }
}

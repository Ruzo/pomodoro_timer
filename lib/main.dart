import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/app.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
import 'package:pomodoro_timer/timer/_manager/timer_manager.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';

void main() {
  registerViewModel();
  runApp(const PomodoroTimerApp());
}

void registerViewModel() {
  GetIt.I.registerSingleton<TasksService>(TasksService());
  GetIt.I.registerSingletonAsync<TasksManager>(() async {
    final tasksManager = TasksManager();
    await tasksManager.initData.executeWithFuture();
    return tasksManager;
  });
  GetIt.I.registerSingletonWithDependencies<TimerService>(
    () => TimerService(),
    dependsOn: [TasksManager],
  );
  GetIt.I.registerSingletonWithDependencies<TimerManager>(
    () => TimerManager(),
    dependsOn: [TimerService, TasksManager],
  );
}

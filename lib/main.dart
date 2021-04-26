import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pomodoro_timer/app.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
import 'package:pomodoro_timer/timer/_manager/timer_manager.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';

void main() {
  registerViewModel();
  runApp(App());
}

void registerViewModel() {
  GetIt.I.registerSingleton<TasksService>(TasksService());
  GetIt.I.registerSingleton<TimerService>(TimerService());
  GetIt.I.registerSingleton<TasksManager>(TasksManager());
  GetIt.I.registerSingleton<TimerManager>(TimerManager());
}

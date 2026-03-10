import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';
import 'package:pomodoro_timer/timer/_manager/timer_manager.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';

class Controls extends StatelessWidget {
  const Controls({super.key});

  @override
  Widget build(BuildContext context) {
    var ts = GetIt.I<TimerService>();
    var tkm = GetIt.I<TasksManager>();
    var tm = GetIt.I<TimerManager>();

    final timerIsRunning = ts.timerIsRunning.watch(context);
    final taskIsDone = tkm.taskIsDone.watch(context);

    return Center(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: .3, sigmaY: .3),
        child: Ink(
          width: 70,
          height: 70,
          decoration: ShapeDecoration(
            color: taskIsDone ? kBackgroundLiteColor : kPrimaryColor,
            shape: const CircleBorder(),
            shadows: [
              BoxShadow(
                color: kPrimaryColor.withAlpha((0.7 * 255).round()),
                blurRadius: 20.0,
              ),
            ],
          ),
          child: IconButton(
            color: Colors.white,
            disabledColor: Colors.blueGrey[800],
            iconSize: 35,
            mouseCursor: taskIsDone
                ? SystemMouseCursors.forbidden
                : SystemMouseCursors.click,
            icon: timerIsRunning
                ? const ImageIcon(
                    AssetImage('icons/icons8-pause-100-white-blured.png'),
                  )
                : const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: ImageIcon(
                      AssetImage('icons/icons8-play-100-white-blured.png'),
                    ),
                  ),
            onPressed: taskIsDone
                ? null
                : !timerIsRunning
                    ? () => tm.startTimer()
                    : () => tm.stopTimer(),
          ),
        ),
      ),
    );
  }
}

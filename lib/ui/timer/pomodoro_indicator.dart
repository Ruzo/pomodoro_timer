import 'package:flutter/material.dart';
import 'package:pomodoro_timer/constants.dart';

class PomodoroIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ...indicatorItemsList(),
          ],
        ),
      ),
    );
  }
}

List<Widget> indicatorItemsList() {
  List<Widget> dotsAndLinesList = [];

  for (int i = 0; i < pomodoros.length; i++) {
    final bool currentPomodoro = pomodoros[i]['current']!;
    final bool pomodoroIsDone = pomodoros[i]['done']!;
    bool drawBreak = false;
    bool breakIsCurrentOrDone = false;

    if (i < breaks.length) {
      drawBreak = true;
      breakIsCurrentOrDone = breaks[i]['current']! || breaks[i]['done']!;
    }

    dotsAndLinesList.add(
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pomodoroIsDone
              ? kPrimaryColor
              : currentPomodoro
                  ? kBackgroundColor
                  : kBackgroundLiteColor,
          border: Border.all(
            color: currentPomodoro ? kPrimaryColor : Colors.transparent,
            width: 4,
          ),
        ),
        width: currentPomodoro ? 20 : 12,
        height: currentPomodoro ? 20 : 12,
      ),
    );

    if (drawBreak) {
      dotsAndLinesList.add(
        Container(
          height: 2,
          width: 20,
          color: breakIsCurrentOrDone ? kPrimaryColor : kBackgroundLiteColor,
        ),
      );
    }
  }

  return dotsAndLinesList;
}

List<Map<String, bool>> pomodoros = [
  {
    'done': true,
    'current': false,
  },
  {
    'done': true,
    'current': false,
  },
  {
    'done': false,
    'current': true,
  },
  {
    'done': false,
    'current': false,
  },
];
List<Map<String, bool>> breaks = [
  {
    'done': true,
    'current': false,
  },
  {
    'done': true,
    'current': false,
  },
  {
    'done': false,
    'current': false,
  },
];

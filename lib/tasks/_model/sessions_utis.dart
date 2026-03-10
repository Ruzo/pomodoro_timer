import 'package:pomodoro_timer/tasks/_model/pomodoro.dart';
import 'package:pomodoro_timer/tasks/_model/session.dart';

List<Session> generateSessions(
  List<Pomodoro> pomodoros,
  Duration shortBreak,
  Duration longBreak,
  int longBreakInterval,
) {
  var sessionsList = <Session>[];

  if (pomodoros.isEmpty) {
    return sessionsList;
  }

  // Add the first pomodoro
  sessionsList.add(
    Session(
      duration: pomodoros.first.duration,
      type: SessionType.pomodoro,
    ),
  );

  for (var i = 0; i < pomodoros.length - 1; i++) {
    // Add break session
    if (((i + 1) % longBreakInterval == 0)) {
      sessionsList.add(
        Session(
          type: SessionType.longBreak,
          duration: longBreak,
        ),
      );
    } else {
      sessionsList.add(
        Session(
          type: SessionType.shortBreak,
          duration: shortBreak,
        ),
      );
    }
    // Add the next pomodoro
    sessionsList.add(
      Session(
        duration: pomodoros[i + 1].duration,
        type: SessionType.pomodoro,
      ),
    );
  }
  return sessionsList;
}

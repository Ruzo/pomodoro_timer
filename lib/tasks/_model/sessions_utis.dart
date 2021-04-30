import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_model/Session.dart';

List<Session> generateSessions(
  pomodoros,
  shortBreak,
  longBreak,
  longBreakInterval,
) {
  List<Session> _sessionsList = [];
  for (int i = 0; i < pomodoros.length; i++) {
    int _lastPomodoro = pomodoros.length - 1;
    _sessionsList.add(
      Session(
        duration: pomodoros[i].duration,
        type: SessionType.pomodoro,
      ),
    );
    if (i != _lastPomodoro) {
      i == longBreakInterval - 1
          ? _sessionsList.add(
              Session(
                duration: longBreak,
                type: SessionType.long_break,
              ),
            )
          : _sessionsList.add(
              Session(
                duration: shortBreak,
                type: SessionType.short_break,
              ),
            );
    }
  }
  return _sessionsList;
}

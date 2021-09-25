import 'package:pomodoro_timer/tasks/_model/pomodoro.dart';
import 'package:pomodoro_timer/tasks/_model/session.dart';

List<Session> generateSessions(
  List<Pomodoro> pomodoros,
  Duration shortBreak,
  Duration longBreak,
  int longBreakInterval,
) {
  var _sessionsList = <Session>[];
  for (var i = 0; i < pomodoros.length; i++) {
    var _lastPomodoro = pomodoros.length - 1;
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
                type: SessionType.longBreak,
              ),
            )
          : _sessionsList.add(
              Session(
                duration: shortBreak,
                type: SessionType.shortBreak,
              ),
            );
    }
  }
  return _sessionsList;
}

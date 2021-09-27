import 'package:flutter/material.dart';
import 'package:pomodoro_timer/tasks/_model/session.dart';
import 'package:pomodoro_timer/constants.dart';

/// Text widget of total session time
class TotalTimeText extends StatelessWidget {
  /// Total session time to be displayed
  final int totalMinutes;

  /// Current timer session
  final Session session;

  /// Instance of Text created from total session time int
  /// and colored depending on type.
  const TotalTimeText({
    Key? key,
    required this.totalMinutes,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var s = totalMinutes > 1 ? 's' : '';
    var text = '${totalMinutes.toString()} min$s';

    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        color: (session.type == SessionType.pomodoro) //
            ? kPrimaryColor.withOpacity(.85)
            : kAlternateColor,
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:pomodoro_timer/constants.dart';
import 'package:pomodoro_timer/tasks/_model/session.dart';
import 'package:pomodoro_timer/tasks/_services/tasks_service.dart';
import 'package:pomodoro_timer/timer/_services/timer_service.dart';

/// Widget for progress indicator showing current session within the task.
class PomodoroIndicator extends StatelessWidget {
  const PomodoroIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    var ts = GetIt.I<TasksService>();
    var sessions = ts.sessions.watch(context);
    final currentSession = ts.currentSessionIndex.watch(context);
    
    return Center(
      child: SizedBox(
        height: 20,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IndicatorItemsList(
                sessions: sessions,
                currentSession: currentSession,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IndicatorItemsList extends StatelessWidget {
  final List<Session> sessions;
  final int currentSession;

  const IndicatorItemsList({
    super.key,
    required this.sessions,
    required this.currentSession,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List<Widget>.generate(
        sessions.length,
        (index) {
          var session = sessions[index];
          var isCurrent = currentSession == index;

          switch (session.type) {
            case SessionType.pomodoro:
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isCurrent && !session.done)
                      ? kBackgroundColor
                      : session.done
                          ? kPrimaryColor.withValues(alpha: .85)
                          : kBackgroundLiteColor,
                  border: Border.all(
                    color: (isCurrent && !session.done) ? kPrimaryColor.withValues(alpha: .85) : Colors.transparent,
                    width: 4,
                  ),
                ),
                width: (isCurrent && !session.done) ? 20 : 12,
                height: (isCurrent && !session.done) ? 20 : 12,
              );
            case SessionType.shortBreak:
              return BreakLineWidget(
                context: context,
                session: session,
                width: 20.0,
                isCurrent: isCurrent,
              );
            case SessionType.longBreak:
              return BreakLineWidget(
                context: context,
                session: session,
                width: 30.0,
                isCurrent: isCurrent,
              );
          }
        },
      ),
    );
  }
}

class BreakLineWidget extends StatelessWidget {
  final BuildContext context;
  final Session session;
  final double width;
  final bool isCurrent;

  const BreakLineWidget({
    super.key,
    required this.context,
    required this.session,
    required this.width,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 2,
          width: width,
          color: session.done ? kPrimaryColor.withValues(alpha: .85) : kBackgroundLiteColor,
        ),
        Watch((context) {
          final percent = GetIt.I<TimerService>().percentageDone.value;
          return Container(
            height: 2,
            width: isCurrent ? (width * percent) : width,
            color: (session.done || isCurrent) ? kPrimaryColor.withValues(alpha: .85) : kBackgroundLiteColor,
          );
        }),
      ],
    );
  }
}

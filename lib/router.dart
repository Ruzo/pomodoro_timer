import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_timer/main_screen.dart';
import 'package:pomodoro_timer/timer/timer_screen.dart';
import 'package:pomodoro_timer/timer/ui/add_timer_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/timer',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const Center(
                child: Text('Calendar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timer',
              builder: (context, state) => const TimerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/add_timer',
              builder: (context, state) => const AddTimerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const Center(
                child: Text('Profile', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

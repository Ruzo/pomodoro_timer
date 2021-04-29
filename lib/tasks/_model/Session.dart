import 'dart:convert';

import 'package:pomodoro_timer/constants.dart';

class Session {
  final Duration duration;
  final SessionType type;
  bool done;
  Session({
    required this.duration,
    required this.type,
    this.done = false,
  });

  Session copyWith({
    Duration? duration,
    SessionType? type,
    bool? done,
  }) {
    return Session(
      duration: duration ?? this.duration,
      type: type ?? this.type,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'duration': duration,
      'type': type,
      'done': done,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      duration: map['duration'],
      type: map['type'],
      done: map['done'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Session.fromJson(String source) => Session.fromMap(json.decode(source));

  @override
  String toString() => 'Session(duration: $duration, type: $type, done: $done)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Session && other.duration == duration && other.type == type && other.done == done;
  }

  @override
  int get hashCode => duration.hashCode ^ type.hashCode ^ done.hashCode;
}
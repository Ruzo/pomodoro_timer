import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:pomodoro_timer/constants.dart';

@immutable
class Pomodoro {
  final Duration duration;

  const Pomodoro({
    this.duration = kDefaultTotalTime,
  });

  Pomodoro copyWith({
    Duration? duration,
  }) {
    return Pomodoro(
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'duration': duration,
    };
  }

  factory Pomodoro.fromMap(Map<String, dynamic> map) {
    return Pomodoro(
      duration: map['duration'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Pomodoro.fromJson(String source) => Pomodoro.fromMap(json.decode(source));

  @override
  String toString() => 'Pomodoro(duration: $duration)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pomodoro && other.duration == duration;
  }

  @override
  int get hashCode => duration.hashCode;
}

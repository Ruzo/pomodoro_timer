import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:pomodoro_timer/tasks/_model/pomodoro.dart';

class Task {
  String id;
  final String title;
  final List<Pomodoro> pomodoros;
  final Duration shortBreak;
  final Duration longBreak;
  final int longBreakInterval;

  Task({
    this.id = '',
    this.title = 'No Title',
    this.pomodoros = const [],
    this.shortBreak = const Duration(minutes: 5),
    this.longBreak = const Duration(minutes: 15),
    this.longBreakInterval = 4,
  }) {
    id = Uuid().v1();
  }

  Task defaultTimer() {
    return Task(
      title: 'Default timer',
      pomodoros: const [Pomodoro(), Pomodoro(), Pomodoro(), Pomodoro()],
      shortBreak: const Duration(minutes: 1),
      longBreak: const Duration(minutes: 2),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    List<Pomodoro>? pomodoros,
    Duration? shortBreak,
    Duration? longBreak,
    int? longBreakInterval,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      pomodoros: pomodoros ?? this.pomodoros,
      shortBreak: shortBreak ?? this.shortBreak,
      longBreak: longBreak ?? this.longBreak,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pomodoros': pomodoros.map((x) => x.toMap()).toList(),
      'shortBreak': shortBreak,
      'longBreak': longBreak,
      'longBreakInterval': longBreakInterval,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      pomodoros: List<Pomodoro>.from(map['pomodoros']?.map((x) => Pomodoro.fromMap(x))),
      shortBreak: map['shortBreak'],
      longBreak: map['longBreak'],
      longBreakInterval: map['longBreakInterval'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Task(id: $id, title: $title, pomodoros: $pomodoros, shortBreak: $shortBreak, longBreak: $longBreak, longBreakInterval: $longBreakInterval)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        listEquals(other.pomodoros, pomodoros) &&
        other.shortBreak == shortBreak &&
        other.longBreak == longBreak &&
        other.longBreakInterval == longBreakInterval;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        pomodoros.hashCode ^
        shortBreak.hashCode ^
        longBreak.hashCode ^
        longBreakInterval.hashCode;
  }
}

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/constants.dart';

/// Theme for colors and font
ThemeData darkTheme = ThemeData.dark().copyWith(
  backgroundColor: kBackgroundColor,
  primaryColor: kPrimaryColor,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: kAccentColor),
  textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'AvenirNext'),
);

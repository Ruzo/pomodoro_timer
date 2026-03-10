import 'package:flutter/material.dart';
import 'package:pomodoro_timer/constants.dart';

/// Theme for colors and font
ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: kPrimaryColor,
  textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'AvenirNext'),
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(secondary: kAccentColor)
      .copyWith(surface: kBackgroundColor),
);

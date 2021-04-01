import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro_timer/constants.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    backgroundColor: kBackgroundColor,
    primaryColor: kPrimaryColor,
    accentColor: kAccentColor,
    textTheme: GoogleFonts.quicksandTextTheme(),
  );
}

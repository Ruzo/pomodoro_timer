import 'dart:math';

import 'package:flutter/material.dart';

// colors
const Color kBackgroundColor = Color.fromARGB(255, 26, 22, 38);
const Color kBackgroundLiteColor = Color(0xFF2D2C40);
const Color kPrimaryColor = Color(0xFF664EFF);
const Color kAlternateColor = Color(0xAA7B1FA2);
const Color kAccentColor = Color(0xFF6C4EB3);
const Color kBackgroundNeutralColor = Color(0xFF25243A);

// painter angle const values
const double kStartAngle = 0.0;
const double kSweepAngle = 2 * pi;

const Duration kDefaultTotalTime = Duration(minutes: 1);

// enums
enum Direction { forward, inReverse, forwardZeroCrossed, reverseZeroCrossed }
enum LimitReached { start, end, none }

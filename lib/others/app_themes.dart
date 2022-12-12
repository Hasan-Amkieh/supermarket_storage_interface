import 'dart:math';


import 'package:flutter/material.dart';

import '../main.dart';

/*const List<List<Color>> darkThemeScheduleColors = [ // TODO: Complete this: // Or maybe not! / maybe use both for white and dark themes!
  [Colors.blue, Colors.grey], // The first is for background color, the second is text color,
];*/

class AppTheme {

  static List<Color> scheduleColors_ = [
    const Color.fromRGBO(84, 125, 141, 1.0),
    const Color.fromRGBO(102, 132, 89, 1.0),
    const Color.fromRGBO(141, 163, 153, 1.0),
    const Color.fromRGBO(70, 136, 185, 1.0),
    const Color.fromRGBO(38, 110, 115, 1.0),
    const Color.fromRGBO(104, 184, 141, 1.0),
    const Color.fromRGBO(54, 117, 136, 1.0),
    const Color.fromRGBO(50, 134, 149, 1.0),
    const Color.fromRGBO(10, 166, 62, 1.0),
    const Color.fromRGBO(128, 105, 103, 1.0),
    const Color.fromRGBO(20, 130, 200, 1.0),
    const Color.fromRGBO(215, 194, 135, 1.0),
    const Color.fromRGBO(93, 138, 168, 1.0),
    const Color.fromRGBO(156, 63, 189, 1.0),
    const Color.fromRGBO(176, 172, 178, 1.0),
    const Color.fromRGBO(190, 146, 182, 1.0),
    const Color.fromRGBO(163, 193, 173, 1.0),
    const Color.fromRGBO(254, 195, 21, 1.0),
  ];

  static Color getColor(int index) {
    if (index < scheduleColors_.length) {
      scheduleColors_.add(Colors.primaries[Random().nextInt(Colors.primaries.length)].shade400);
    }

    return scheduleColors_[index];
  }

  TextStyle headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white);

  Color normalTextColor = Colors.white;

  Color titleTextColor = Colors.white;

  Color subtitleTextColor = Colors.grey.shade400;

  TextStyle headerSchedulePageTextStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

  Color headerBackgroundColor = Colors.grey.shade900;

  Color periodBackgroundColor = const Color.fromRGBO(13, 38, 35, 1.0).withOpacity(0.8);

  Color scheduleBackgroundColor =  Colors.grey.shade800;

  Color navigationBarColor = const Color.fromRGBO(48, 48, 48, 1.0);

  Color navIconColor = Colors.white;

  Color titleIconColor = Colors.white;

  Color scaffoldBackgroundColor = const Color.fromRGBO(13, 38, 35, 1.0);

  Color emptyCellColor = Colors.grey.shade800;

  Color textfieldBackgroundColor = Colors.grey.shade600;

  Brightness keyboardTheme = Brightness.dark;

  Color hintTextColor = Colors.grey.shade500;

  AppTheme() {
    ;
  }

  Color getRandomColor() {

    return Colors.primaries[Random().nextInt(Colors.primaries.length)];

  }

}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TimeOfDay parseTimeOfDayString(String str) {
  var parts = str.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

String padTwoZeros(int number) {
  final NumberFormat formatter = NumberFormat('00');
  return formatter.format(number);
}

String buildDateDisplayString(
  DateTime dateTime, {
  Locale locale = const Locale('en'),
}) {
  final DateFormat formatter =
      locale.languageCode == 'jp' ? DateFormat('MM月dd日') : DateFormat('MM/dd');
  return formatter.format(dateTime);
}

String buildDayDisplayStringEN(DateTime dateTime) {
  switch (dateTime.weekday) {
    case 1:
      return 'MON';
    case 2:
      return 'TUE';
    case 3:
      return 'WED';
    case 4:
      return 'THU';
    case 5:
      return 'FRI';
    case 6:
      return 'SAT';
    case 7:
      return 'SUN';
    default:
      return '';
  }
}

String buildDayDisplayStringJP(DateTime dateTime) {
  switch (dateTime.weekday) {
    case 1:
      return '月曜日';
    case 2:
      return '火曜日';
    case 3:
      return '水曜日';
    case 4:
      return '木曜日';
    case 5:
      return '金曜日';
    case 6:
      return '土曜日';
    case 7:
      return '日曜日';
    default:
      return '';
  }
}

String buildTimeDisplayString(TimeOfDay timeOfDay) {
  return '${padTwoZeros(timeOfDay.hour)}:${padTwoZeros(timeOfDay.minute)}';
}

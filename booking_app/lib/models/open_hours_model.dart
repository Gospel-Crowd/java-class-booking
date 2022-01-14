import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OpenHours {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  late String documentId;

  OpenHours({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.documentId = '',
  });

  OpenHours.fromJson(Map<String, dynamic>? json, String documentId)
      : this(
          date: DateTime.fromMicrosecondsSinceEpoch(
              (json?['date']! as Timestamp).microsecondsSinceEpoch),
          startTime: _parseTimeOfDayString(json?['startTime'] as String),
          endTime: _parseTimeOfDayString(json?['endTime'] as String),
          documentId: documentId,
        );

  static TimeOfDay _parseTimeOfDayString(String str) {
    var parts = str.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Map<String, Object?> toJson() {
    return {
      'date': date,
      'startTime': getStartTimeDisplayString(),
      'endTime': getEndTimeDisplayString(),
    };
  }

  String getDateDisplayString({Locale locale = const Locale('en')}) {
    return buildDateDisplayString(date, locale: locale);
  }

  String getDayDisplayString({Locale locale = const Locale('en')}) {
    return locale.languageCode == 'jp'
        ? buildDayDisplayStringJP(date)
        : buildDayDisplayStringEN(date);
  }

  String getStartTimeDisplayString() {
    return buildTimeDisplayString(startTime);
  }

  String getEndTimeDisplayString() {
    return buildTimeDisplayString(endTime);
  }

  static String _padTwoZeros(int number) {
    final NumberFormat formatter = NumberFormat('00');
    return formatter.format(number);
  }

  static String buildDateDisplayString(
    DateTime dateTime, {
    Locale locale = const Locale('en'),
  }) {
    final DateFormat formatter = locale.languageCode == 'jp'
        ? DateFormat('MM月dd日')
        : DateFormat('MM/dd');
    return formatter.format(dateTime);
  }

  static String buildDayDisplayStringEN(DateTime dateTime) {
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

  static String buildDayDisplayStringJP(DateTime dateTime) {
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

  static String buildTimeDisplayString(TimeOfDay timeOfDay) {
    return '${_padTwoZeros(timeOfDay.hour)}:${_padTwoZeros(timeOfDay.minute)}';
  }
}

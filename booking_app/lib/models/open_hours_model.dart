import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OpenHours {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String documentId;

  OpenHours({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.documentId,
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

  String getDateDisplayString() {
    return buildDateDisplayString(date);
  }

  String getDayDisplayString() {
    return buildDayDisplayString(date);
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

  static String buildDateDisplayString(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MM/dd');
    return formatter.format(dateTime);
  }

  static String buildDayDisplayString(DateTime dateTime) {
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

  static String buildTimeDisplayString(TimeOfDay timeOfDay) {
    return '${_padTwoZeros(timeOfDay.hour)}:${_padTwoZeros(timeOfDay.minute)}';
  }
}

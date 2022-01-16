import 'package:booking_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          startTime: parseTimeOfDayString(json?['startTime'] as String),
          endTime: parseTimeOfDayString(json?['endTime'] as String),
          documentId: documentId,
        );

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
}

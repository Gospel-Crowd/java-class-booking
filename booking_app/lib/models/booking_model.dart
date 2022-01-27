import 'package:booking_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Booking {
  String userId;
  String userDisplayName;
  String userMailId;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  late String documentId;

  Booking({
    required this.userId,
    required this.userDisplayName,
    required this.userMailId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.documentId = '',
  });

  Booking.fromJson(Map<String, dynamic>? json, String documentId)
      : this(
          userId: json?['userId'] as String,
          userDisplayName: json?['userDisplayName'] as String,
          userMailId: json?['userMailId'] as String,
          date: DateTime.fromMicrosecondsSinceEpoch(
              (json?['date']! as Timestamp).microsecondsSinceEpoch),
          startTime: parseTimeOfDayString(json?['startTime'] as String),
          endTime: parseTimeOfDayString(json?['endTime'] as String),
          documentId: documentId,
        );

  Map<String, Object?> toJson() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userMailId': userMailId,
      'date': date,
      'startTime': buildTimeDisplayString(startTime),
      'endTime': buildTimeDisplayString(endTime),
    };
  }
}

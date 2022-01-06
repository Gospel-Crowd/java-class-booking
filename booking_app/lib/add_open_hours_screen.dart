import 'package:booking_app/models/open_hours_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddOpenHoursScreen extends StatefulWidget {
  const AddOpenHoursScreen({Key? key}) : super(key: key);

  @override
  _AddOpenHoursScreenState createState() => _AddOpenHoursScreenState();
}

class _AddOpenHoursScreenState extends State<AddOpenHoursScreen> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  final CollectionReference _openHoursRef = FirebaseFirestore.instance
      .collection('open-hours')
      .withConverter<OpenHours>(
        fromFirestore: (snapshot, _) => OpenHours.fromJson(snapshot.data()!),
        toFirestore: (openHours, _) => openHours.toJson(),
      );

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);
  List<TimeOfDay> _availableTimes = [];

  List<TimeOfDay> _calculateAvailableTimes(
      TimeOfDay startTime, TimeOfDay endTime) {
    List<TimeOfDay> availableTimes = [];
    for (var i = startTime.hour; i <= endTime.hour; i++) {
      availableTimes.add(TimeOfDay(hour: i, minute: 0));
      if (i != endTime.hour) {
        availableTimes.add(TimeOfDay(hour: i, minute: 30));
      }
    }
    return availableTimes;
  }

  @override
  void initState() {
    super.initState();

    _availableTimes = _calculateAvailableTimes(_startTime, _endTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Open Hours'),
        actions: [
          IconButton(
            onPressed: () {
              _openHoursRef
                  .add(OpenHours(
                    date: _selectedDate,
                    startTime: _startTime,
                    endTime: _endTime,
                  ))
                  .then((value) => Navigator.pop(context))
                  .catchError((error) {
                Navigator.pop(context);
              });
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              const Text('Date'),
              const SizedBox(width: 16),
              Text(formatter.format(_selectedDate)),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2022),
                lastDate: DateTime(2023),
              );

              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: const Text('Select'),
          ),
          Row(
            children: [
              const Text('Start Time'),
              const SizedBox(width: 16),
              Text('${_startTime.hour}:${_startTime.minute}'),
            ],
          ),
          DropdownButton(
            items: _availableTimes
                .map<DropdownMenuItem<TimeOfDay>>((TimeOfDay value) {
              return DropdownMenuItem<TimeOfDay>(
                value: value,
                child: Text('${value.hour}:${value.minute}'),
              );
            }).toList(),
            onChanged: (TimeOfDay? newValue) {
              setState(() {
                _startTime = newValue!;
              });
            },
          ),
          Row(
            children: [
              const Text('End Time'),
              const SizedBox(width: 16),
              Text('${_endTime.hour}:${_endTime.minute}'),
            ],
          ),
          DropdownButton(
            items: _availableTimes
                .map<DropdownMenuItem<TimeOfDay>>((TimeOfDay value) {
              return DropdownMenuItem<TimeOfDay>(
                value: value,
                child: Text('${value.hour}:${value.minute}'),
              );
            }).toList(),
            onChanged: (TimeOfDay? newValue) {
              setState(() {
                _endTime = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }
}

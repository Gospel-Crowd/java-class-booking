import 'package:booking_app/colors.dart';
import 'package:booking_app/database.dart';
import 'package:booking_app/models/open_hours_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddEditOpenHoursScreen extends StatefulWidget {
  const AddEditOpenHoursScreen({Key? key, required this.openHours})
      : super(key: key);

  final OpenHours openHours;

  @override
  _AddEditOpenHoursScreenState createState() => _AddEditOpenHoursScreenState();
}

class _AddEditOpenHoursScreenState extends State<AddEditOpenHoursScreen> {
  final CollectionReference _openHoursRef = FirebaseFirestore.instance
      .collection(openHoursCollection)
      .withConverter<OpenHours>(
        fromFirestore: (snapshot, _) =>
            OpenHours.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (openHours, _) => openHours.toJson(),
      );

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.openHours.date;
    _startTime = widget.openHours.startTime;
    _endTime = widget.openHours.endTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDatePicker(),
              const VerticalDivider(width: 16, color: primaryColor),
              _buildStartTimePicker(),
              const Text(
                '-',
                style: TextStyle(fontSize: 32),
              ),
              _buildEndTimePicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndTimePicker() {
    return GestureDetector(
      child: Text(
        OpenHours.buildTimeDisplayString(_endTime),
        style: const TextStyle(fontSize: 32),
      ),
      onTap: () async {
        final TimeOfDay? pickedEndTime = await showTimePicker(
          context: context,
          initialTime: _endTime,
        );

        if (pickedEndTime != null) {
          setState(() {
            _endTime = pickedEndTime;
          });
        }
      },
    );
  }

  Widget _buildStartTimePicker() {
    return GestureDetector(
      child: Text(
        OpenHours.buildTimeDisplayString(_startTime),
        style: const TextStyle(fontSize: 32),
      ),
      onTap: () async {
        final TimeOfDay? pickedStartTime = await showTimePicker(
          context: context,
          initialTime: _startTime,
        );

        if (pickedStartTime != null) {
          setState(() {
            _startTime = pickedStartTime;
            _endTime = pickedStartTime.replacing(
              hour: pickedStartTime.hour + 2,
            );
          });
        }
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            OpenHours.buildDateDisplayString(_selectedDate),
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(
            OpenHours.buildDayDisplayStringEN(_selectedDate),
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2022),
          lastDate: DateTime(2023),
        );

        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Add Open Hours'),
      actions: [
        IconButton(
          onPressed: () {
            if (widget.openHours.documentId == '') {
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
            } else {
              _openHoursRef
                  .doc(widget.openHours.documentId)
                  .set(OpenHours(
                    date: _selectedDate,
                    startTime: _startTime,
                    endTime: _endTime,
                    documentId: widget.openHours.documentId,
                  ))
                  .then((value) => Navigator.pop(context))
                  .catchError((error) {
                Navigator.pop(context);
              });
            }
          },
          icon: const Icon(Icons.done),
          iconSize: 32,
        ),
      ],
    );
  }
}

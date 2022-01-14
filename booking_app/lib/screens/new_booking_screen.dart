import 'package:booking_app/colors.dart';
import 'package:booking_app/database.dart';
import 'package:booking_app/models/open_hours_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewBookingScreen extends StatefulWidget {
  const NewBookingScreen({Key? key}) : super(key: key);

  @override
  _NewBookingScreenState createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  final _openHoursStream = FirebaseFirestore.instance
      .collection(openHoursCollection)
      .withConverter<OpenHours>(
        fromFirestore: (snapshot, _) =>
            OpenHours.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (openHours, _) => openHours.toJson(),
      )
      .snapshots();

  int _convertToTotalMinutes(TimeOfDay timeOfDay) =>
      timeOfDay.hour * 60 + timeOfDay.minute;

  TimeOfDay _convertToTimeOfDay(int totalMinutes) =>
      TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);

  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();
    _selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規予約'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.done),
            iconSize: 32,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _openHoursStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return _buildBody(_convertToOpenHoursList(snapshot.data!.docs));
        },
      ),
    );
  }

  Widget _buildBody(List<OpenHours> openHoursDataItems) {
    var jpLocale = const Locale('jp');
    List<Widget> widgets = [];

    for (var ohdItem in openHoursDataItems) {
      widgets.add(_buildDateAndDayHeading(ohdItem, jpLocale));

      widgets.add(_buildOpenTimeSlotGrid(ohdItem));

      widgets.add(const SizedBox(height: 16));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: ListView(
        children: widgets,
      ),
    );
  }

  Widget _buildOpenTimeSlotGrid(OpenHours openHours) {
    List<Widget> gridViewWidgets = [];

    for (int minutes = _convertToTotalMinutes(openHours.startTime);
        minutes + 120 <= _convertToTotalMinutes(openHours.endTime);
        minutes = minutes + 30) {
      gridViewWidgets.add(_buildOpenTimeSlot(
        openHours.date,
        _convertToTimeOfDay(minutes),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GridView.count(
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        crossAxisCount: 5,
        children: gridViewWidgets,
        shrinkWrap: true,
        childAspectRatio: 1.5,
      ),
    );
  }

  Widget _buildOpenTimeSlot(DateTime date, TimeOfDay timeOfDay) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          _selectedStartTime = timeOfDay;
        });
      },
      child: Container(
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
          color: _selectedDate == date && _selectedStartTime == timeOfDay
              ? primaryColor
              : null,
          border: Border.all(
            color: primaryColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(
          OpenHours.buildTimeDisplayString(timeOfDay),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDateAndDayHeading(OpenHours ohdItem, Locale jpLocale) {
    return Text(
      ohdItem.getDateDisplayString(locale: jpLocale) +
          ' ' +
          ohdItem.getDayDisplayString(locale: jpLocale),
      style: const TextStyle(fontSize: 24),
    );
  }

  List<OpenHours> _convertToOpenHoursList(
    List<QueryDocumentSnapshot<Object?>> docs,
  ) {
    List<OpenHours> openHoursDataItems = docs.map((DocumentSnapshot document) {
      return document.data() as OpenHours;
    }).toList();

    openHoursDataItems.sort((a, b) {
      var dateDiff =
          a.getDateDisplayString().compareTo(b.getDateDisplayString());

      if (dateDiff == 0) {
        return a
            .getStartTimeDisplayString()
            .compareTo(b.getStartTimeDisplayString());
      }

      return dateDiff;
    });

    return openHoursDataItems;
  }
}

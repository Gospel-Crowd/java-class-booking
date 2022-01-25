import 'package:booking_app/colors.dart';
import 'package:booking_app/database.dart';
import 'package:booking_app/models/booking_model.dart';
import 'package:booking_app/models/open_hours_model.dart';
import 'package:booking_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AddEditBookingScreen extends StatefulWidget {
  const AddEditBookingScreen(
      {Key? key, required this.booking, required this.signedInUser})
      : super(key: key);

  final Booking booking;
  final GoogleSignInAccount? signedInUser;

  @override
  _AddEditBookingScreenState createState() => _AddEditBookingScreenState();
}

class _AddEditBookingScreenState extends State<AddEditBookingScreen> {
  final Locale jpLocale = const Locale('jp');

  final _openHoursStream = FirebaseFirestore.instance
      .collection(openHoursCollection)
      .withConverter<OpenHours>(
        fromFirestore: (snapshot, _) =>
            OpenHours.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (openHours, _) => openHours.toJson(),
      )
      .snapshots();

  final CollectionReference _bookingsRef = FirebaseFirestore.instance
      .collection(bookingsCollection)
      .withConverter<Booking>(
        fromFirestore: (snapshot, _) =>
            Booking.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (booking, _) => booking.toJson(),
      );

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
          _buildDoneButton(context),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: _openHoursStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> openHoursSnapshot) {
        if (openHoursSnapshot.hasError) {
          return const Text('エラーが出ました');
        }

        if (openHoursSnapshot.connectionState == ConnectionState.waiting) {
          return const Text("ローディング中");
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _bookingsRef.snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> bookingSnapshot) {
            if (bookingSnapshot.hasError) {
              return const Text('エラーが出ました');
            }

            if (bookingSnapshot.connectionState == ConnectionState.waiting) {
              return const Text("ローディング中");
            }

            return _buildBodyInternal(
              _convertToOpenHoursList(openHoursSnapshot.data!.docs),
              _convertToBookings(bookingSnapshot.data!.docs),
            );
          },
        );
      },
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (widget.booking.documentId == '') {
          _bookingsRef
              .add(Booking(
                userId: widget.signedInUser!.id,
                userDisplayName: widget.signedInUser!.displayName!,
                userMailId: widget.signedInUser!.email,
                date: _selectedDate,
                startTime: _selectedStartTime,
                endTime: TimeOfDay(
                  hour: (_selectedStartTime.hour + 2) % 24,
                  minute: _selectedStartTime.minute,
                ),
              ))
              .then((value) => Navigator.pop(context))
              .catchError((error) {
            Navigator.pop(context);
          });
        } else {
          _bookingsRef
              .doc(widget.booking.documentId)
              .set(Booking(
                userId: widget.signedInUser!.id,
                userDisplayName: widget.signedInUser!.displayName!,
                userMailId: widget.signedInUser!.email,
                date: _selectedDate,
                startTime: _selectedStartTime,
                endTime: TimeOfDay(
                  hour: (_selectedStartTime.hour + 2) % 24,
                  minute: _selectedStartTime.minute,
                ),
              ))
              .then((value) => Navigator.pop(context))
              .catchError((error) {
            Navigator.pop(context);
          });
        }
      },
      icon: const Icon(Icons.done),
      iconSize: 32,
    );
  }

  Widget _buildBodyInternal(
    List<OpenHours> openHoursDataItems,
    List<Booking> bookingDataItems,
  ) {
    List<Widget> widgets = [];

    for (var ohdItem in openHoursDataItems) {
      widgets.addAll(_buildOpenTimeSlotGrid(ohdItem, bookingDataItems));

      widgets.add(const SizedBox(height: 16));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: ListView(
        children: widgets,
      ),
    );
  }

  bool isConflict(DateTime date, int startMinutes, List<Booking> bookings) {
    int numberOfConflicts = 0;
    int endMinutes = startMinutes + 120;

    for (var booking in bookings) {
      int bStartMinutes = _convertToTotalMinutes(booking.startTime);
      int bEndMinutes = _convertToTotalMinutes(booking.endTime);
      if (booking.date.compareTo(date) == 0 &&
          startMinutes < bEndMinutes &&
          endMinutes > bStartMinutes) {
        numberOfConflicts++;
      }
    }

    return numberOfConflicts >= 3;
  }

  List<Widget> _buildOpenTimeSlotGrid(
    OpenHours openHours,
    List<Booking> bookingDataItems,
  ) {
    List<Widget> gridViewWidgets = [];

    for (int minutes = _convertToTotalMinutes(openHours.startTime);
        minutes + 120 <= _convertToTotalMinutes(openHours.endTime);
        minutes = minutes + 30) {
      if (!isConflict(
        openHours.date,
        minutes,
        bookingDataItems,
      )) {
        gridViewWidgets.add(_buildOpenTimeSlot(
          openHours.date,
          _convertToTimeOfDay(minutes),
        ));
      }
    }

    return gridViewWidgets.isEmpty
        ? []
        : [
            _buildDateAndDayHeading(openHours),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GridView.count(
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                crossAxisCount: 5,
                children: gridViewWidgets,
                shrinkWrap: true,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
              ),
            )
          ];
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
          buildTimeDisplayString(timeOfDay),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDateAndDayHeading(OpenHours ohdItem) {
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

  List<Booking> _convertToBookings(List<QueryDocumentSnapshot<Object?>> docs) {
    return docs.map((DocumentSnapshot document) {
      return document.data() as Booking;
    }).toList();
  }
}

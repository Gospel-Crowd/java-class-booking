import 'package:booking_app/colors.dart';
import 'package:booking_app/database.dart';
import 'package:booking_app/models/booking_model.dart';
import 'package:booking_app/screens/add_edit_booking_screen.dart';
import 'package:booking_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class BookingsListing extends StatefulWidget {
  const BookingsListing({Key? key, this.signedInUser, this.readOnly = false})
      : super(key: key);

  final GoogleSignInAccount? signedInUser;
  final bool readOnly;

  @override
  _BookingsListingState createState() => _BookingsListingState();
}

class _BookingsListingState extends State<BookingsListing> {
  final CollectionReference _bookingRef =
      FirebaseFirestore.instance.collection(bookingsCollection);

  @override
  Widget build(BuildContext context) {
    final _bookingsStream = FirebaseFirestore.instance
        .collection(bookingsCollection)
        .where('userMailId', isEqualTo: widget.signedInUser?.email)
        .where(
          'date',
          isGreaterThan: DateTime.now().subtract(const Duration(days: 1)),
        )
        .withConverter<Booking>(
          fromFirestore: (snapshot, _) =>
              Booking.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (booking, _) => booking.toJson(),
        )
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _bookingsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('エラーが出ました');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("ローディング中");
        }

        return _buildBodyInternal(_convertToBookingList(snapshot.data!.docs));
      },
    );
  }

  Widget _buildBodyInternal(List<Booking> bookingDataItems) {
    List<Widget> widgets = [];

    widgets.add(const SizedBox(height: 8));
    widgets.add(const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        '予約済み',
        style: TextStyle(fontSize: 16),
      ),
    ));

    for (var item in bookingDataItems) {
      widgets.add(_buildBookingItem(item));
      widgets.add(const SizedBox(height: 8));
    }

    return ListView(
      children: widgets,
    );
  }

  Widget _buildBookingItem(Booking booking) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _buildDateDisplay(booking),
                const VerticalDivider(width: 16, color: primaryColor),
                _buildTimeDisplay(booking),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(Booking booking) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.readOnly ? Container() : const SizedBox(height: 12),
          Text(
            buildTimeDisplayString(booking.startTime) +
                ' - ' +
                buildTimeDisplayString(booking.endTime),
            style: const TextStyle(fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  booking.userDisplayName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              widget.readOnly ? Container() : _buildButtonBar(booking),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonBar(Booking booking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditBookingScreen(
                  booking: booking,
                  signedInUser: widget.signedInUser,
                ),
              ),
            );
          },
          icon: const Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () async {
            await _bookingRef.doc(booking.documentId).delete();
          },
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  Widget _buildDateDisplay(Booking booking) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          buildDateDisplayString(booking.date, locale: const Locale('jp')),
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          buildDayDisplayStringJP(booking.date),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  List<Booking> _convertToBookingList(
    List<QueryDocumentSnapshot<Object?>> docs,
  ) {
    List<Booking> bookingDataItems = docs.map((DocumentSnapshot document) {
      return document.data() as Booking;
    }).toList();

    bookingDataItems.sort((a, b) {
      var dateDiff = buildDateDisplayString(a.date)
          .compareTo(buildDateDisplayString(b.date));

      if (dateDiff == 0) {
        return buildTimeDisplayString(a.startTime)
            .compareTo(buildTimeDisplayString(b.startTime));
      }

      return dateDiff;
    });

    return bookingDataItems;
  }
}

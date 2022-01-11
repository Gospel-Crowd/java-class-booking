import 'package:flutter/material.dart';

class BookingsListing extends StatefulWidget {
  const BookingsListing({Key? key}) : super(key: key);

  @override
  _BookingsListingState createState() => _BookingsListingState();
}

class _BookingsListingState extends State<BookingsListing> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'BOOKINGS',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}

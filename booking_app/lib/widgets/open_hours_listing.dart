import 'package:booking_app/colors.dart';
import 'package:booking_app/database.dart';
import 'package:booking_app/models/open_hours_model.dart';
import 'package:booking_app/screens/add_edit_open_hours_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OpenHoursListing extends StatefulWidget {
  const OpenHoursListing({Key? key}) : super(key: key);

  @override
  _OpenHoursListingState createState() => _OpenHoursListingState();
}

class _OpenHoursListingState extends State<OpenHoursListing> {
  final _openHoursStream = FirebaseFirestore.instance
      .collection(openHoursCollection)
      .withConverter<OpenHours>(
        fromFirestore: (snapshot, _) =>
            OpenHours.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (openHours, _) => openHours.toJson(),
      )
      .snapshots();

  final CollectionReference _openHoursRef =
      FirebaseFirestore.instance.collection(openHoursCollection);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _openHoursStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        List<Widget> widgets = [];

        widgets.add(const SizedBox(height: 8));
        widgets.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'OPEN HOURS',
            style: TextStyle(fontSize: 20),
          ),
        ));

        List<OpenHours> openHoursDataItems =
            _convertToOpenHoursList(snapshot.data!.docs);

        for (var item in openHoursDataItems) {
          widgets.add(_buildOpenHoursItem(item));
          widgets.add(const SizedBox(height: 8));
        }

        return ListView(
          children: widgets,
        );
      },
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

  Widget _buildOpenHoursItem(OpenHours openHours) {
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
                _buildDateDisplay(openHours),
                const VerticalDivider(width: 16, color: primaryColor),
                _buildTimeDisplay(openHours),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(OpenHours openHours) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            openHours.getStartTimeDisplayString() +
                ' - ' +
                openHours.getEndTimeDisplayString(),
            style: const TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditOpenHoursScreen(
                        openHours: openHours,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () async {
                  await _openHoursRef.doc(openHours.documentId).delete();
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(OpenHours openHours) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          openHours.getDateDisplayString(),
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          openHours.getDayDisplayString(),
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}

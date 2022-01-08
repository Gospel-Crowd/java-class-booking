import 'package:booking_app/screens/add_edit_open_hours_screen.dart';
import 'package:booking_app/colors.dart';
import 'package:booking_app/database.dart';
import 'package:booking_app/models/open_hours_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  GoogleSignInAccount? _currentUser;

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

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async => await _googleSignIn.disconnect();

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return _currentUser != null ? _buildHomeView() : _buildLoginView();
  }

  Widget _buildHomeView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: _buildHomeBody(),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(_currentUser!.email),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: _handleSignOut,
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddOpenHoursButton(),
    );
  }

  Widget _buildAddOpenHoursButton() {
    return IconButton(
      icon: const Icon(Icons.add_circle),
      iconSize: 60,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditOpenHoursScreen(
              openHours: OpenHours(
                documentId: '',
                date: DateTime.now(),
                startTime: const TimeOfDay(hour: 9, minute: 0),
                endTime: const TimeOfDay(hour: 11, minute: 0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeBody() {
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

  Scaffold _buildLoginView() {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('SIGN IN'),
          onPressed: _handleSignIn,
        ),
      ),
    );
  }
}

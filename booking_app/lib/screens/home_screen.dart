import 'package:booking_app/main.dart';
import 'package:booking_app/models/open_hours_model.dart';
import 'package:booking_app/screens/add_edit_open_hours_screen.dart';
import 'package:booking_app/screens/new_booking_screen.dart';
import 'package:booking_app/widgets/bookings_listing.dart';
import 'package:booking_app/widgets/open_hours_listing.dart';
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

        // Mark the user as admin if the user email is samuel.anudeep@gmail.com
        isAdmin = account?.id == '104008690092105020153';
      });
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return _currentUser != null ? _buildHomeView() : _buildLoginView();
  }

  Widget _buildHomeView() {
    return isAdmin
        ? _buildAdminHomeView()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
            ),
            body: const BookingsListing(),
            drawer: _buildDrawer(),
            floatingActionButton: IconButton(
              icon: const Icon(Icons.add_circle),
              iconSize: 60,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewBookingScreen(),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildDrawer() {
    return Drawer(
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
    );
  }

  Widget _buildAdminHomeView() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.schedule)),
              Tab(icon: Icon(Icons.library_books)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OpenHoursListing(),
            BookingsListing(),
          ],
        ),
        drawer: _buildDrawer(),
        floatingActionButton: _buildAddOpenHoursButton(),
      ),
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

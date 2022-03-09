import 'package:booking_app/main.dart';
import 'package:booking_app/models/booking_model.dart';
import 'package:booking_app/models/open_hours_model.dart';
import 'package:booking_app/models/user_model.dart';
import 'package:booking_app/screens/add_edit_booking_screen.dart';
import 'package:booking_app/screens/add_edit_open_hours_screen.dart';
import 'package:booking_app/widgets/bookings_listing.dart';
import 'package:booking_app/widgets/open_hours_listing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple_sign_in;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserModel _signedInUser;
  bool _signedIn = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<void> _handleGoogleSignOut() async {
    await _googleSignIn.disconnect();
    setState(() {
      _signedIn = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _signedInUser = UserModel(
          id: account!.id,
          displayName: account.displayName!,
          email: account.email,
          accountType: AccountType.google,
        );

        // Mark the user as admin if the user email is samuel.anudeep@gmail.com
        isAdmin = account.id == '104008690092105020153';
      });
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return _signedIn ? _buildHomeView() : _buildLoginView();
  }

  Widget _buildHomeView() {
    return isAdmin
        ? _buildAdminHomeView()
        : Scaffold(
            appBar: AppBar(
              title: const Text('ホーム'),
            ),
            body: BookingsListing(userModel: _signedInUser),
            drawer: _buildDrawer(),
            floatingActionButton: IconButton(
              icon: const Icon(Icons.add_circle),
              iconSize: 60,
              onPressed: () {
                if (_signedIn) {}
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditBookingScreen(
                      booking: Booking(
                        userId: _signedInUser.id,
                        userDisplayName: _signedInUser.displayName,
                        userMailId: _signedInUser.email,
                        date: DateTime.now(),
                        startTime: const TimeOfDay(hour: 9, minute: 0),
                        endTime: const TimeOfDay(hour: 11, minute: 0),
                      ),
                      userModel: _signedInUser,
                    ),
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
            child: Text(
              _signedInUser.email,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: const Text('ログアウト'),
            onTap: _handleGoogleSignOut,
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
            BookingsListing(readOnly: true),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                child: const Text(
                  'Googleでログイン',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  await _googleSignIn.signIn();
                  setState(() {
                    _signedIn = true;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              width: 200,
              child: apple_sign_in.AppleSignInButton(
                type: apple_sign_in.ButtonType.continueButton,
                style: apple_sign_in.ButtonStyle.black,
                buttonText: 'Appleでログイン',
                onPressed: _signInWithApple,
                //cornerRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signInWithApple() async {
    final apple_sign_in.AuthorizationResult result =
        await apple_sign_in.TheAppleSignIn.performRequests([
      const apple_sign_in.AppleIdRequest(requestedScopes: [
        apple_sign_in.Scope.email,
        apple_sign_in.Scope.fullName,
      ])
    ]);

    if (result.status == apple_sign_in.AuthorizationStatus.authorized) {
      final apple_sign_in.AppleIdCredential appleIdCredential =
          result.credential!;

      OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: String.fromCharCodes(appleIdCredential.identityToken!),
        accessToken: String.fromCharCodes(appleIdCredential.authorizationCode!),
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      assert(!firebaseUser.isAnonymous);
      assert(firebaseUser.uid == FirebaseAuth.instance.currentUser!.uid);

      setState(() {
        _signedInUser = UserModel(
          id: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? firebaseUser.email!,
          email: firebaseUser.email!,
          accountType: AccountType.apple,
        );

        _signedIn = true;
      });
    }
  }
}

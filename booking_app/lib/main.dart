import 'package:booking_app/colors.dart';
import 'package:booking_app/firebase_options.dart';
import 'package:booking_app/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

bool isAdmin = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BookingApp());
}

class BookingApp extends StatelessWidget {
  const BookingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oasis Tokyo',
      theme: _buildThemeData(context),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildThemeData(BuildContext context) {
    var defaultThemeData = Theme.of(context);
    var textTheme = _buildTextTheme(defaultThemeData);

    return defaultThemeData.copyWith(
      primaryColor: primaryColor,
      iconTheme: const IconThemeData(color: primaryColor),
      textTheme: textTheme,
      inputDecorationTheme: defaultThemeData.inputDecorationTheme.copyWith(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(primaryColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            return primaryColor;
          }),
        ),
      ),
      dividerColor: const Color.fromRGBO(193, 193, 193, 1),
      appBarTheme: _buildAppBarTheme(defaultThemeData),
      tabBarTheme: _buildTabTheme(defaultThemeData, textTheme),
    );
  }

  TabBarTheme _buildTabTheme(ThemeData defaultThemeData, TextTheme textTheme) {
    return defaultThemeData.tabBarTheme.copyWith(
      labelColor: primaryColor,
      unselectedLabelColor: primaryColor,
      labelStyle: textTheme.headline4,
      unselectedLabelStyle: textTheme.headline4,
    );
  }

  AppBarTheme _buildAppBarTheme(ThemeData defaultThemeData) {
    return defaultThemeData.appBarTheme.copyWith(
      shadowColor: Colors.transparent,
      color: Colors.white,
      foregroundColor: Colors.black,
      titleTextStyle: defaultThemeData.textTheme.titleMedium!.copyWith(
        color: Colors.black,
      ),
    );
  }

  TextTheme _buildTextTheme(ThemeData defaultThemeData) {
    return defaultThemeData.textTheme
        .copyWith(
          headline1: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
          headline2: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          headline3: const TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          headline4: const TextStyle(
            fontSize: 16,
          ),
          button: const TextStyle(
            fontSize: 18,
          ),
          headline5: const TextStyle(
            color: primaryColor,
            fontSize: 10,
          ),
        )
        .apply(
          fontFamily: 'NotoSansJP',
          fontSizeDelta: 2,
        );
  }
}

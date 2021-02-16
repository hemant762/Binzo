import 'package:app/screens/wellcome/wellcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application. mandi bazaar
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mandi Bazaar',
      theme: ThemeData(
          textTheme:
          GoogleFonts.dmSansTextTheme().apply(displayColor: kTextColor),
          canvasColor: Colors.transparent,
          appBarTheme: AppBarTheme(
            color: Colors.transparent,
            elevation: 0,
            brightness: Brightness.light,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primarySwatch: Colors.blue,
          accentColor: kPrimaryColor
      ),
      home: WellcomeScreen(),
    );
  }
}
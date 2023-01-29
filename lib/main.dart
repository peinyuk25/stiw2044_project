import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homestay_raya/pages/splashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOMESTAY RAYA',
      theme: ThemeData(
        textTheme: GoogleFonts.patrickHandTextTheme(
            Theme.of(context).textTheme.apply()),
        primarySwatch: Colors.blueGrey,
      ),
      home: const SplashScreen(),
    );
  }
}

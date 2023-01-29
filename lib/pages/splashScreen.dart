import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:homestay_raya/User.dart';
import 'package:homestay_raya/pages/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../config.dart';
import 'homeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            //put image + background color
            Text("Homestay Raya",
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
            CircularProgressIndicator(),
            Text("Version 0.1",
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold)),
          ],
        )),
      ),
    );
  }

  Future<void> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _email = (prefs.getString('email')) ?? '';
    String _pass = (prefs.getString('pass')) ?? '';
    if (_email.isNotEmpty) {
      http.post(Uri.parse("${Config.SERVER}/homestayraya/php/login_user.php"),
          body: {"email": _email, "password": _pass}).then((response) {
        var jsonResponse = json.decode(response.body);
        if (response.statusCode == 200 && jsonResponse['status'] == "success") {
          var jsonResponse = json.decode(response.body);
          User user = User.fromJson(jsonResponse['data']);
          Timer(
              const Duration(seconds: 3),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => HomeScreen(user: user))));
        } else {
          User user = User(
              id: "0",
              email: "unregistered",
              name: "unregistered",
              phone: "0123456789",
              regdate: "0",
              credit: '0');
          Timer(
              const Duration(seconds: 3),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => HomeScreen(user: user))));
        }
      });
    } else {
      User user = User(
          id: "0",
          email: "unregistered",
          name: "unregistered",
          phone: "0123456789",
          regdate: "0",
          credit: '0');
      Timer(
          const Duration(seconds: 3),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (content) => HomeScreen(user: user))));
    }
  }
}

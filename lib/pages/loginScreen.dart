import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homestay_raya/User.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/pages/homeScreen.dart';
import 'package:homestay_raya/pages/registrationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  final User user;

  const LoginScreen({super.key, required this.user});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();

  bool _passwordVisible = true;
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  //will change follow the orientation of phone
  var screenHeight, screenWidth;
  double cardwidth = 0.0;

  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth <= 600.00) {
      cardwidth = 400.00;
    } else {
      cardwidth = screenHeight;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: cardwidth,
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                            controller: _emailEditingController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val!.isEmpty ||
                                    !val.contains("@") ||
                                    !val.contains(".")
                                ? "enter a valid email"
                                : null,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.email),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ))),
                        TextFormField(
                          controller: _passEditingController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(),
                            icon: const Icon(Icons.password),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(width: 1.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Checkbox(
                              value: _isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isChecked = value!;
                                  saveremovepref(value);
                                });
                              },
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  _goHome();
                                },
                                child: const Text('Remember Me',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ),
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              minWidth: 115,
                              height: 50,
                              elevation: 10,
                              onPressed: _loginDialog,
                              color: Theme.of(context).colorScheme.primary,
                              child: const Text('Login'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text("Don't have an account?",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                                const SizedBox(
                                  width: 7.0,
                                ),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3.0)),
                                  color: Colors.lightGreen.shade300,
                                  onPressed: () {
                                    _goRegisterDialog();
                                  },
                                  child: const Text(
                                    "Register Now",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ]),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loginDialog() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the form first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Login?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _loginUser();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _loginUser() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please fill in the login credentials",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    String _email = _emailEditingController.text;
    String _pass = _passEditingController.text;
    http.post(Uri.parse("${Config.SERVER}/homestayraya/php/login_user.php"),
        body: {"email": _email, "password": _pass}).then((response) {
      // print(response.body);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == "success") {
        var jsonResponse = json.decode(response.body);
        // print(jsonResponse);
        User user = User.fromJson(jsonResponse['data']);
        Navigator.push(context,
            MaterialPageRoute(builder: (content) => HomeScreen(user: user)));
        Fluttertoast.showToast(
            msg: "Login Successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      } else {
        Fluttertoast.showToast(
            msg: "Login Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      }
    });
  }

  void _goHome() {
    Navigator.push(context,
        MaterialPageRoute(builder: (content) => HomeScreen(user: widget.user)));
  }

  void _goRegisterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Go to Register",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?"),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => RegistrationScreen(
                              user: widget.user,
                            )));
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void saveremovepref(bool value) async {
    String email = _emailEditingController.text;
    String password = _passEditingController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      if (!_formKey.currentState!.validate()) {
        Fluttertoast.showToast(
            msg: "Please fill in the login details",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        _isChecked = false;
        return;
      }
      //save preferences
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      Fluttertoast.showToast(
          msg: "User information has been stored",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      _isChecked = false;
      return;
    } else {
      //delete preference
      await prefs.setString('email', '');
      await prefs.setString('pass', '');
      setState(() {
        _emailEditingController.text = '';
        _passEditingController.text = '';
        _isChecked = false;
      });
      Fluttertoast.showToast(
          msg: "User information has been removed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<void> loadPref() async {
    //get information from initState
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    if (email.length > 1) {
      setState(() {
        _emailEditingController.text = email;
        _passEditingController.text = password;
        _isChecked = true;
      });
    }
  }
}

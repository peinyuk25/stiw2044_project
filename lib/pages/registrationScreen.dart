import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homestay_raya/User.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/pages/loginScreen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndialog/ndialog.dart';

import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    super.key,
    required this.user,
  });
  final User user;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  void initState() {
    super.initState();
    loadEula();
  }

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _passaEditingController = TextEditingController();
  final TextEditingController _passbEditingController = TextEditingController();

  bool _isChecked = false;
  bool _passwordVisible = true;
  final _formKey = GlobalKey<FormState>();
  String eula = "";
  File? _image;
  var pathAsset = "assets/profile/profile.png";

  final ImagePicker imagePicker = ImagePicker();
  late List<XFile> imagefiles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registration Form",
          style: TextStyle(fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              GestureDetector(
                  onTap: _selectImageDialog,
                  child: Card(
                    elevation: 6,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: _image == null
                            ? AssetImage(pathAsset)
                            : FileImage(_image!) as ImageProvider,
                        fit: BoxFit.cover,
                      )),
                    ),
                  )),
              Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        TextFormField(
                            controller: _nameEditingController,
                            keyboardType: TextInputType.text,
                            validator: (val) => validateName(val.toString()),
                            decoration: const InputDecoration(
                                labelText: ('Name'),
                                labelStyle: TextStyle(fontSize: 20),
                                icon: Icon(Icons.person),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ))),
                        TextFormField(
                            controller: _emailEditingController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => validateEmail(val.toString()),
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(fontSize: 20),
                                icon: Icon(Icons.email),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ))),
                        TextFormField(
                            controller: _phoneEditingController,
                            keyboardType: TextInputType.phone,
                            validator: (val) => validatePhone(val.toString()),
                            decoration: const InputDecoration(
                                labelText: 'Phone',
                                labelStyle: TextStyle(fontSize: 20),
                                icon: Icon(Icons.phone),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ))),
                        TextFormField(
                            controller: _passaEditingController,
                            keyboardType: TextInputType.visiblePassword,
                            validator: (val) =>
                                validatePassword(val.toString()),
                            obscureText: _passwordVisible,
                            decoration: InputDecoration(
                              labelText: 'at least 10-digit Password',
                              labelStyle: const TextStyle(fontSize: 20),
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
                            )),
                        TextFormField(
                            controller: _passbEditingController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _passwordVisible,
                            decoration: InputDecoration(
                              labelText: 'Retype Password',
                              labelStyle: const TextStyle(fontSize: 20),
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
                            )),
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
                                });
                              },
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: showEula,
                                child: const Text('Agree with TERMS',
                                    style: TextStyle(
                                      fontSize: 20,
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
                              onPressed: _registerAccountDialog,
                              color: Theme.of(context).colorScheme.primary,
                              child: const Text('Register',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ],
                        ),
                        const Text("Have an account?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                        MaterialButton(
                          onPressed: _goToLogin,
                          color: Theme.of(context).colorScheme.primary,
                          child: const Text('Go Login',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ]),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String? validateName(String name) {
    if (name.isEmpty || name.length < 3) {
      return "Name must be longer than 3";
    } else {
      return null;
    }
  }

  String? validateEmail(String email) {
    if (email.isEmpty || !email.contains("@") || !email.contains(".")) {
      return "Enter a valid email";
    } else {
      return null;
    }
  }

  String? validatePhone(String phone) {
    if (phone.isEmpty || phone.length < 10) {
      return "Please enter a valid phone number";
    } else {
      return null;
    }
  }

  String? validatePassword(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{10,}$';
    RegExp regex = RegExp(pattern);
    if (value.isEmpty) {
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(value)) {
        return 'Should have 1 uppercase, 1 lowercase, 1 number';
      } else {
        return null;
      }
    }
  }

  Future<void> loadEula() async {
    WidgetsFlutterBinding.ensureInitialized();
    eula = await rootBundle.loadString('assets/eula.txt');
  }

  void showEula() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "EULA TERMS",
            style: TextStyle(),
          ),
          content: SizedBox(
            height: 300,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: RichText(
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                        text: eula),
                  )),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Close",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _registerAccountDialog() {
    String _name = _nameEditingController.text;
    String _email = _emailEditingController.text;
    String _phone = _phoneEditingController.text;
    String _passa = _passaEditingController.text;
    String _passb = _passbEditingController.text;

    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the registration form first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (!_isChecked) {
      Fluttertoast.showToast(
          msg: "Please Accept Term",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (_passa != _passb) {
      Fluttertoast.showToast(
          msg: "Please check your passsword",
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
            "Register new account?",
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
                _registerUser(_name, _email, _phone, _passa);
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

  void _registerUser(String name, String email, String phone, String passa) {
    ProgressDialog dialog = ProgressDialog(context,
        message: const Text("Progressing..."),
        title: const Text("Register Account"));
    dialog.show();

    String base64Image = base64Encode(_image!.readAsBytesSync());

    try {
      http.post(
          Uri.parse("${Config.SERVER}/homestayraya/php/register_user.php"),
          body: {
            "name": name,
            "email": email,
            "phone": phone,
            "password": passa,
            "register": "register",
            "image": base64Image
          }).then((response) {
        print(response);
        var data = jsonDecode(response.body);
        var rescode = response.statusCode;
        // print(rescode);
        print(data);
        if (rescode == 200 && data['status'] == "success") {
          Fluttertoast.showToast(
              msg: "Success. Please login",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (content) => LoginScreen(
                        user: widget.user,
                      )));
          return;
        } else {
          Fluttertoast.showToast(
              msg: "Failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          dialog.dismiss();
          return;
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _goToLogin() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => LoginScreen(user: widget.user)));
  }

  void _selectImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              "Select from",
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                    onPressed: () => {
                          Navigator.of(context).pop(),
                          _onGallery(),
                        },
                    icon: const Icon(Icons.browse_gallery),
                    label: const Text("Gallery")),
                TextButton.icon(
                    onPressed: () => {Navigator.of(context).pop(), _onCamera()},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera")),
              ],
            ));
      },
    );
  }

  Future<void> _onCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    } else {
      print('No image selected.');
    }
  }

  Future<void> _onGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
      setState(() {});
    }
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
    }
  }
}

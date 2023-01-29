import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homestay_raya/User.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/pages/addServiceScreen.dart';
import 'package:homestay_raya/pages/customerScreen.dart';
import 'package:homestay_raya/pages/detailScreen.dart';
import 'package:homestay_raya/pages/mainMenuScreen.dart';
import 'package:homestay_raya/pages/registrationScreen.dart';
import 'package:homestay_raya/product.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';

class NewServiceScreen extends StatefulWidget {
  final User user;
  const NewServiceScreen({super.key, required this.user});

  @override
  State<NewServiceScreen> createState() => _NewServiceScreenState();
}

class _NewServiceScreenState extends State<NewServiceScreen> {
  var _lat, _lng;
  late Position position;
  List<Product> productList = <Product>[];
  String titleCenter = "Loading services...";
  var placemark;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenHeight, screenWidth, resWidth;
  int rowCount = 2;

  TextEditingController searchController = TextEditingController();
  String search = "all";

  var color;
  var numofpage, curpage = 1;
  int numberofresult = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadProducts("all", 1);
    });
  }

  @override
  void dispose() {
    productList = [];
    print("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      rowCount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      rowCount = 3;
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        decoration: BoxDecoration(color: Colors.lightBlue.shade100),
        child: Scaffold(
            appBar: AppBar(
                title: const Text("Seller"),
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () {
                        _gotoNewProduct("all", 1);
                      },
                      icon: const Icon(Icons.plus_one_outlined)),
                  IconButton(
                    icon: const Icon(Icons.search_outlined),
                    onPressed: () {
                      _loadSearchDialog();
                    },
                  )
                ]),
            body: productList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(titleCenter,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Your current products/services $numberofresult found)",
                          style: (const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      GestureDetector(
                        onTap: () {
                          _registrationForm();
                        },
                        child: Container(
                          color: Theme.of(context).primaryColorLight,
                          padding: const EdgeInsets.all(4),
                          child:
                              const Text('No account? Chick here to Register!',
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      GestureDetector(
                        onTap: () {
                          goCustomerScreen();
                        },
                        child: Container(
                          color: Theme.of(context).highlightColor,
                          padding: const EdgeInsets.all(4),
                          child: const Text('Go to Customer Side',
                              style: TextStyle(
                                fontSize: 20,
                              )),
                        ),
                      ),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: rowCount,
                          children: List.generate(productList.length, (index) {
                            return Card(
                              elevation: 8,
                              child: InkWell(
                                onTap: () {
                                  _showDetails(index, "all", 1);
                                },
                                onLongPress: () {
                                  _deleteDialog(index);
                                },
                                child: Column(children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: CachedNetworkImage(
                                      width: resWidth / 2,
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          "${Config.SERVER}/homestayraya/assets/images/${productList[index].productId}.png",
                                      placeholder: (context, url) =>
                                          const LinearProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  Flexible(
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              truncateString(
                                                  productList[index]
                                                      .productName
                                                      .toString(),
                                                  15),
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                "RM ${double.parse(productList[index].productPrice.toString()).toStringAsFixed(2)}"),
                                          ],
                                        ),
                                      ))
                                ]),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: numofpage,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            if ((curpage - 1) == index) {
                              color = const Color.fromARGB(255, 64, 114, 251);
                            } else {
                              color = Colors.black;
                            }
                            return SizedBox(
                              width: 50,
                              child: TextButton(
                                  onPressed: () =>
                                      {_loadProducts(search, index + 1)},
                                  child: Text(
                                    (index + 1).toString(),
                                    style:
                                        TextStyle(color: color, fontSize: 18),
                                  )),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            drawer: MainMenuScreen(user: widget.user)),
      ),
    );
  }

  validatorProductName(String name) {
    if (name.isEmpty || name.length < 3) {
      return "Name must be longer than 3";
    } else {
      return null;
    }
  }

  void _registrationForm() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => RegistrationScreen(user: widget.user)));
  }

  Future<void> _showDetails(int index, String searchName, int pageno) async {
    Product product = Product.fromJson(productList[index].toJson());
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => DetailsScreen(
                  product: product,
                  user: widget.user,
                )));
    _loadProducts(searchName, pageno);
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  Future<void> _gotoNewProduct(String searchName, int pageno) async {
    searchName = "all";
    pageno = 1;
    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please login/register",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 10,
      message: const Text("Searching your current location"),
      title: null,
    );
    progressDialog.show();
    if (await _checkPermissionGetLoc()) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => AddServiceScreen(
                    position: position,
                    user: widget.user,
                    placemarks: placemark,
                  )));
      _loadProducts(searchName, pageno);
    } else {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<bool> _checkPermissionGetLoc() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Please allow the app to access the location",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Geolocator.openLocationSettings();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      Geolocator.openLocationSettings();
      return false;
    }
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    try {
      placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      Fluttertoast.showToast(
          msg:
              "Error in fixing your location. Make sure internet connection is available and try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return false;
    }
    return true;
  }

  _loadProducts(String name, int pageno) {
    curpage = pageno;
    numofpage ?? 1;
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 5,
      message: const Text("Loading..."),
      title: null,
    );
    progressDialog.show();

    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please register an account first", //Show toast
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      titleCenter = "Please register an account";
      setState(() {});
      progressDialog.dismiss();
      return;
    } else {
      http
          .get(Uri.parse(
              "${Config.SERVER}/homestayraya/php/loadsellerproduct.php?user_id=${widget.user.id}&search=$search&pageno=$pageno"))
          .then((response) {
        if (response.statusCode == 200) {
          var jsondata = jsonDecode(response.body);
          if (jsondata['status'] == 'success') {
            var extractdata = jsondata['data'];
            if (extractdata['products'] != null) {
              numofpage = int.parse(jsondata['numofpage']);
              numberofresult = int.parse(jsondata['numberofresult']);
              productList = <Product>[];
              extractdata['products'].forEach((v) {
                productList.add(Product.fromJson(v));
                print(productList[0].productName);
              });
              titleCenter = "Found";
            } else {
              titleCenter = "No Product Available, Please add a Product";
              productList.clear();
            }
          } else {
            titleCenter = "No Product Available, Please add a Product";
          }
        } else {
          titleCenter = "No Product Available, Please add a Product";
          productList.clear();
        }
        setState(() {});
      });
      progressDialog.dismiss();
    }
  }

  void _deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(
            "Delete ${truncateString(productList[index].productName.toString(), 15)}",
            style: const TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                _deleteProduct(index);
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

  void _deleteProduct(int index) {
    try {
      http.post(
          Uri.parse("${Config.SERVER}/homestayraya/php/delete_product.php"),
          body: {
            "product_id": productList[index].productId,
          }).then((response) {
        var data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['status'] == "success") {
          Fluttertoast.showToast(
              msg: "Success",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          setState(() {
            _loadProducts("all", 1);
          });

          return;
        } else {
          Fluttertoast.showToast(
              msg: "Failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          return;
        }

        //print(response.body);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void goCustomerScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => CustomerScreen(
                  user: widget.user,
                )));
  }

  void _loadSearchDialog() {
    searchController.text = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                title: const Text(
                  "Search ",
                ),
                content: SizedBox(
                  //height: screenHeight / 4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      search = searchController.text;
                      Navigator.of(context).pop();
                      _loadProducts(search, 1);
                    },
                    child: const Text("Search"),
                  )
                ],
              );
            },
          );
        });
  }

  void _goRegister() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => RegistrationScreen(
                  user: widget.user,
                )));
  }
}

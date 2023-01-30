import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homestay_raya/User.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/pages/customerDetailScreen.dart';
import 'package:homestay_raya/pages/mainMenuScreen.dart';
import 'package:homestay_raya/pages/sellerScreen.dart';
import 'package:homestay_raya/product.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';

class CustomerScreen extends StatefulWidget {
  final User user;
  const CustomerScreen({super.key, required this.user});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Product> productList = <Product>[];
  String titlecenter = "Loading...";
  //final df = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenHeight, screenWidth, resWidth;
  int rowcount = 2;

  TextEditingController searchController = TextEditingController();
  String search = "all";

  var color;
  var numofpage, curpage = 1;
  int numberofresult = 0;

  var seller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadProducts("all", 1);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      rowcount = 3;
    }
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Buyers"),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _loadSearchDialog();
                },
              )
            ],
          ),
          body: productList.isEmpty
              ? Center(
                  child: Text(titlecenter,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Products/services $numberofresult found)",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    const Text("Are you a Seller?",
                        style: TextStyle(
                          fontSize: 20,
                        )),
                    GestureDetector(
                      onTap: () {
                        goSellerScreen();
                      },
                      child: Container(
                        color: Theme.of(context).primaryColorLight,
                        padding: const EdgeInsets.all(4),
                        child: const Text('PRESS HERE',
                            style: TextStyle(
                              fontSize: 20,
                            )),
                      ),
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: rowcount,
                        children: List.generate(productList.length, (index) {
                          return Card(
                            elevation: 8,
                            child: InkWell(
                              onTap: () {
                                _showDetails(index);
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
                          return TextButton(
                              onPressed: () =>
                                  {_loadProducts(search, index + 1)},
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(color: color, fontSize: 18),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
          drawer: MainMenuScreen(user: widget.user),
        ));
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  void goSellerScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => NewServiceScreen(
                  user: widget.user,
                )));
  }

  void _loadProducts(String name, int pageno) {
    curpage = pageno;
    numofpage ?? 1;
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 5,
      message: const Text("Loading..."),
      title: null,
    );
    progressDialog.show();
    http
        .get(
      Uri.parse(
          "${Config.SERVER}/homestayraya/php/loadallproduct.php?search=$search&pageno=$pageno"),
    )
        .then((response) {
      print(response.body);
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
            });
            titlecenter = "Found";
          } else {
            titlecenter = "No Service Available";
            productList.clear();
          }
        }
      } else {
        titlecenter = "No Service Available";
        productList.clear();
      }
      setState(() {});
    });
    setState(() {});
    progressDialog.dismiss();
  }

  _showDetails(int index) async {
    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please register an account",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    Product product = Product.fromJson(productList[index].toJson());
    loadSingleSeller(index);
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 5,
      message: const Text("Loading..."),
      title: null,
    );
    progressDialog.show();
    Timer(const Duration(seconds: 1), () {
      if (seller != null) {
        progressDialog.dismiss();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (content) => CustomersDetailsScreen(
                      user: widget.user,
                      product: product,
                      seller: seller,
                    )));
      }
      progressDialog.dismiss();
    });
  }

  void _loadSearchDialog() {
    searchController.text = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
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

  loadSingleSeller(int index) {
    http.post(Uri.parse("${Config.SERVER}/homestayraya/php/load_seller.php"),
        body: {"sellerid": productList[index].userId}).then((response) {
      print(response.body);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == "success") {
        seller = User.fromJson(jsonResponse['data']);
      }
    });
  }
}

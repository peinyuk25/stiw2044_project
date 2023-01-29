import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:homestay_raya/User.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/pages/customerDetail.dart';
import 'package:homestay_raya/pages/customerScreen.dart';
import 'package:homestay_raya/pages/homeScreen.dart';
import 'package:homestay_raya/pages/sellerScreen.dart';

class MainMenuScreen extends StatefulWidget {
  final User user;
  const MainMenuScreen({super.key, required this.user});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 200,
      child: Container(
        alignment: Alignment.topLeft,
        color: Colors.lightBlue.shade100,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue.shade100),
              accountName: Text(
                widget.user.email.toString(),
                style: const TextStyle(color: Colors.black),
              ),
              accountEmail: Text(
                widget.user.name.toString(),
                style: const TextStyle(color: Colors.black),
              ),
              currentAccountPicture: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: CachedNetworkImage(
                  imageUrl:
                      "${Config.SERVER}/homestayraya/assets/profileimages/${widget.user.id}.png",
                  placeholder: (context, url) =>
                      const LinearProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.image_not_supported,
                    size: 128,
                  ),
                ),
              ),
              onDetailsPressed: goCustomerDetail,
            ),
            const Divider(
              thickness: 4,
            ),
            ListTile(
              title: const Text('Home Page'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => HomeScreen(user: widget.user)));
              },
            ),
            ListTile(
              title: const Text('Services: Seller Side'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) =>
                            NewServiceScreen(user: widget.user)));
              },
            ),
            ListTile(
              title: const Text('Services: Customer Side'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) =>
                            CustomerScreen(user: widget.user)));
              },
            ),
            ListTile(
              title: const Text('Customer Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) =>
                            CustomerDetails(user: widget.user)));
              },
            ),
          ],
        ),
      ),
    );
  }

  void goCustomerDetail() {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => CustomerDetails(user: widget.user)));
  }
}

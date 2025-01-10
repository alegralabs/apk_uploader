// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/pages/account.dart';
import 'package:readybill/pages/add_product.dart';
import 'package:readybill/pages/change_password_page.dart';

import 'package:readybill/pages/home_page.dart';
import 'package:readybill/pages/login_page.dart';
import 'package:readybill/pages/preferences.dart';
import 'package:readybill/pages/add_employee.dart';
import 'package:readybill/pages/subscriptions.dart';
import 'package:readybill/pages/support.dart';
import 'package:readybill/pages/transaction_list.dart';
import 'package:readybill/pages/view_inventory.dart';
import 'package:readybill/services/api_services.dart';
import 'package:readybill/services/global_internet_connection_handler.dart';

import 'package:readybill/services/result.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String _name = '';

  String imageUrl = '';
  Image? logo;
  int isAdmin = 0;
  String shopName = '';
  String address = '';
  String phone = '';

  final Uri _userDataUrl = Uri.parse('$baseUrl/user-detail');

  @override
  void initState() {
    super.initState();

    _getData();
  }

  Future<void> _getData() async {
    String? token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();
    final response = await http.get(
      _userDataUrl,
      headers: {'Authorization': 'Bearer $token', 'auth-key': '$apiKey'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (mounted) {
        setState(() {
          imageUrl = jsonData['logo'];
          logo = Image.network(imageUrl);
          isAdmin = jsonData['data']['isAdmin'];
          _name = jsonData['data']['name'];
          shopName = jsonData['data']['details']['business_name'];
          address = jsonData['data']['details']['address'];
          phone = jsonData['data']['mobile'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget drawerHeader = Container(
      padding: EdgeInsets.only(
          left: 20,
          top: MediaQuery.of(context).padding.top * 1.5,
          bottom: 10,
          right: 10),
      decoration: const BoxDecoration(
        color: green2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage: logo?.image,
            backgroundColor: green2,
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _name,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 22,
                        fontFamily: 'Roboto_Regular',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isAdmin == 1)
                      const Text(
                        "(Admin)",
                        style: TextStyle(
                          fontFamily: 'Roboto_Regular',
                          fontSize: 18,
                        ),
                      ),
                  ],
                ),
                Text(
                  shopName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: white,
                  ),
                ),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 16,
                    color: white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 16,
                    color: white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, d) async {
          // Navigate to NextPage when user tries to pop MyHomePage
          navigatorKey.currentState?.pushReplacement(
            CupertinoPageRoute(builder: (context) => const HomePage()),
          );
          // Return false to prevent popping the current route
          return; // Return true to allow popping the route
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            drawerHeader,
            isAdmin == 1
                ? ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add Inventory'),
                    onTap: () {
                      navigatorKey.currentState?.push(
                        CupertinoPageRoute(
                            builder: (context) => const AddInventory()),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            isAdmin == 1
                ? ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Update Inventory'),
                    onTap: () {
                      navigatorKey.currentState?.push(
                        CupertinoPageRoute(
                            builder: (context) => const ProductListPage()),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: const Text('Transactions'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(
                      builder: (context) => const TransactionListPage()),
                );
              },
            ),
            isAdmin == 1
                ? ListTile(
                    leading: const Icon(Icons.person_add_outlined),
                    title: const Text('Add Employee'),
                    onTap: () {
                      navigatorKey.currentState?.push(
                        CupertinoPageRoute(
                            builder: (context) => const EmployeeSignUpPage()),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            isAdmin == 1
                ? ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Preferences'),
                    onTap: () {
                      navigatorKey.currentState?.push(
                        CupertinoPageRoute(
                            builder: (context) => const PreferencesPage()),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Account'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(builder: (context) => const UserAccount()),
                );
              },
            ),
            isAdmin == 1
                ? ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: const Text('Change Password'),
                    onTap: () {
                      navigatorKey.currentState?.push(
                        CupertinoPageRoute(
                            builder: (context) => const ChangePasswordPage(
                                  smsType: 'change_password',
                                )),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            isAdmin == 1
                ? ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('Subscription'),
                    onTap: () {
                      navigatorKey.currentState?.push(
                        CupertinoPageRoute(
                          builder: (context) => const Subscriptions(),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(
                    builder: (context) => const ContactSupportPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    EasyLoading.show(status: 'Logging out...');
    try {
      var token = await APIService.getToken();
      var apiKey = await APIService.getXApiKey();
      const String apiUrl = '$baseUrl/logout';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'auth-key': '$apiKey',
        },
      );
      print(response.body);
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        navigatorKey.currentState?.pushReplacement(
          CupertinoPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        print("logout error");
      }
    } catch (e) {
      print("Logout error: $e");
      Result.error("Book list not available");
      // Directly navigate to login screen
      // navigatorKey.currentState?.pushReplacement(
      //   CupertinoPageRoute(builder: (context) => const LoginPage()),
      // );
    }
  }
}

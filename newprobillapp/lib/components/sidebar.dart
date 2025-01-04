// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newprobillapp/components/api_constants.dart';
import 'package:newprobillapp/components/color_constants.dart';
import 'package:newprobillapp/pages/account.dart';
import 'package:newprobillapp/pages/add_product.dart';
import 'package:newprobillapp/pages/forgot_password_page.dart';
import 'package:newprobillapp/pages/home_page.dart';
import 'package:newprobillapp/pages/login_page.dart';
import 'package:newprobillapp/pages/preferences.dart';
import 'package:newprobillapp/pages/employee_signup.dart';
import 'package:newprobillapp/pages/subscriptions.dart';
import 'package:newprobillapp/pages/transaction_list.dart';
import 'package:newprobillapp/pages/view_inventory.dart';
import 'package:newprobillapp/services/api_services.dart';
import 'package:newprobillapp/services/global_internet_connection_handler.dart';

import 'package:newprobillapp/services/result.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      print(jsonData);

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
        print('isAdmin: $isAdmin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget drawerHeader = Container(
      padding: EdgeInsets.only(
          left: 20,
          top: MediaQuery.of(context).padding.top,
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
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Inventory'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(
                      builder: (context) => const AddInventory()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Update Inventory'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(
                      builder: (context) => const ProductListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Transactions'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(
                      builder: (context) => const TransactionListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_rounded),
              title: const Text('Employee'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(
                      builder: (context) => const EmployeeSignUpPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Preferences'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(
                      builder: (context) => const PreferencesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(builder: (context) => const UserAccount()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Change Password'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(
                      builder: (context) => const ForgotPasswordPage(
                            smsType: 'change_password',
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: const Text('Subscription'),
              onTap: () {
                navigatorKey.currentState?.push(
                  CupertinoPageRoute(
                    builder: (context) => const Subscriptions(),
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
      print(response.statusCode);
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        // Directly navigate to login screen
        navigatorKey.currentState?.pushReplacement(
          CupertinoPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // Directly navigate to login screen
        //navigatorKey.currentState?.pushReplacement(
        //   context,
        //   CupertinoPageRoute(builder: (context) => const LoginPage()),
        // );
      }
    } catch (e) {
      Result.error("Book list not available");
      // Directly navigate to login screen
      navigatorKey.currentState?.pushReplacement(
        CupertinoPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}

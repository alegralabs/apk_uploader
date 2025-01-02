import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:newprobillapp/components/api_constants.dart';
import 'package:newprobillapp/components/color_constants.dart';
import 'package:newprobillapp/components/sidebar.dart';
import 'package:newprobillapp/pages/home_page.dart';
import 'package:newprobillapp/pages/login_page.dart';
import 'package:newprobillapp/services/api_services.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool isLoading = false;
  bool maintainMRP = false;
  bool showMRPInInvoice = false;
  bool maintainStock = false;
  bool showHSNSACCode = false;
  bool showHSNSACCodeInInvoice = false;

  int _selectedIndex = 3;

  Future<void> _fetchUserPreferences() async {
    setState(() {
      isLoading = true;
    });

    // Measure the starting time
    var token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();
    // Make API call to fetch user preferences
    const String apiUrl = '$baseUrl/user-preferences';
    final response = await http.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $token',
      'auth-key': '$apiKey',
    });
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final preferencesData = jsonData['data'];
      setState(() {
        maintainMRP = preferencesData['preference_mrp'] == 1 ? true : false;
        showMRPInInvoice =
            preferencesData['preference_mrp_invoice'] == 1 ? true : false;
        maintainStock =
            preferencesData['preference_quantity'] == 1 ? true : false;
        showHSNSACCode = preferencesData['preference_hsn'] == 1 ? true : false;
        showHSNSACCodeInInvoice =
            preferencesData['preference_hsn_invoice'] == 1 ? true : false;
      });
    } else {
      // Handle exceptions

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('An error occurred. Please login and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Redirect to login page
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveUserPreferences() async {
    setState(() {
      isLoading = true;
    });
    var token = await APIService.getToken();
    const String apiUrl = '$baseUrl/prefernce';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'preference_mrp': maintainMRP ? 1 : 0,
        'preference_mrp_invoice': showMRPInInvoice ? 1 : 0,
        'preference_quantity': maintainStock ? 1 : 0,
        'preference_hsn': showHSNSACCode ? 1 : 0,
        'preference_hsn_invoice': showHSNSACCodeInInvoice ? 1 : 0,
      }),
    );
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('User preferences updated successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to update user preferences.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // _fetchUserPreferences();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _fetchUserPreferences());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        // Navigate to NextPage when user tries to pop MyHomePage
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
        // Return false to prevent popping the current route
        return;
      },
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
              'Preferences',
              style: TextStyle(
                color: black,
              ),
            ),
            backgroundColor: green2),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(243, 203, 71, 1),
                  ), // Change color here
                ), // Show loading indicator
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      buildCheckbox('Do you maintain MRP?', maintainMRP,
                          (value) {
                        setState(() {
                          maintainMRP = value!;
                        });
                      }),
                      buildCheckbox('Do you want to show MRP in invoice?',
                          showMRPInInvoice, (value) {
                        setState(() {
                          showMRPInInvoice = value!;
                        });
                      }),
                      buildCheckbox(
                        'Do you want to maintain stock?',
                        maintainStock,
                        (value) {
                          setState(() {
                            maintainStock = value!;
                          });
                        },
                      ),
                      buildCheckbox(
                        'Do you want HSN/ SAC code?',
                        showHSNSACCode,
                        (value) {
                          setState(() {
                            showHSNSACCode = value!;
                          });
                        },
                      ),
                      buildCheckbox(
                        'Do you want to show HSN/ SAC code \nin invoice?',
                        showHSNSACCodeInInvoice,
                        (value) {
                          setState(() {
                            showHSNSACCodeInInvoice = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _saveUserPreferences();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(green2),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget buildCheckbox(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          activeColor: green2,
          value: value,
          onChanged: onChanged,
        ),
        Text(title),
      ],
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/pages/forgot_password_page.dart';
import 'package:readybill/pages/home_page.dart';
import 'package:readybill/pages/sign_up_page.dart';

import 'package:readybill/services/api_services.dart';
import 'package:readybill/services/global_internet_connection_handler.dart';
//import 'package:readybill/services/local_database.dart';
import 'package:readybill/services/local_database_2.dart';
import 'package:readybill/services/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final LocalDatabase2 _localDatabase = LocalDatabase2.instance;
  bool isObscure = true;
  final _loginFormKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _phoneNumberFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _phoneNumberFocusNode.requestFocus();
  }

  @override
  void dispose() {
    // Dispose the controllers to free up resources when the widget is disposed
    phoneNumberController.dispose();
    passwordController.dispose();
    _passwordFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  void showApiResponseDialog(
      BuildContext context, Map<String, dynamic> response) {
    String title;
    String content;

    // Determine title and content based on the response
    if (response['status'] == 'success') {
      title = "Login Successful";
      content = "Welcome to ReadyBill";

      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const HomePage()),
      );
    } else if (response['status'] == 'failed' &&
        response['message'] == 'Validation Error!') {
      title = "Validation Error";
      content = "Please check the following errors:\n";

      // Loop through validation errors
      Map<String, dynamic> errors = response['data'];
      errors.forEach((field, messages) {
        content += "$field: ${messages[0]}\n";
      });
    } else if (response['status'] == 'failed' &&
        response['message'] == 'Invalid credentials') {
      title = "Invalid Credentials";
      content = "Please check your mobile number and password.";
    } else if (response['status'] == 'failed' &&
        response['message'] == 'User Not Found') {
      title = "User Not Found";
      content = "Please check your mobile number and try again.";
    } else {
      title = "ERROR";
      content = response['message'];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return customAlertBox(
          title: title,
          content: content,
          actions: [
            customElevatedButton("OK", green, white, () {
              navigatorKey.currentState?.pop();
            })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: black,
      drawerEnableOpenDragGesture: false, // Disable swipe to open drawer
      body: Form(
        key: _loginFormKey,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: screenHeight * 0.05,
                left: screenWidth * 0.25,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: Image.asset(
                    'assets/man-phone-green.png',
                    width: screenWidth * 0.8,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.35,
                left: screenWidth * 0.1,
                child: const Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Roboto-Bold',
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Positioned(
                bottom: screenHeight * 0.1,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        height: screenHeight * 0.45,
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 30),
                                TextFormField(
                                  cursorColor: green,
                                  focusNode: _phoneNumberFocusNode,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.length < 10 ||
                                        value.length > 10 ||
                                        int.tryParse(value) == null) {
                                      return 'Must be 10-digit Number';
                                    }
                                    return null;
                                  },
                                  textAlignVertical: TextAlignVertical.center,
                                  controller: phoneNumberController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    errorStyle: TextStyle(color: red),
                                    prefixIcon: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "  +91  ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          //  textAlign: TextAlign.,
                                        ),
                                      ],
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: green,
                                    )),
                                    filled: true,
                                    fillColor: white,
                                    hintText: 'Mobile Number',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(7.0),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Minimum 8 Charecters';
                                    }
                                    return null;
                                  },
                                  controller: passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: isObscure,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isObscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isObscure = !isObscure;
                                        });
                                      },
                                    ),
                                    errorStyle: const TextStyle(color: red),
                                    filled: true,
                                    fillColor: white,
                                    hintText: 'Password',
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(7.0),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordPage(
                                                  smsType: "forgot_password",
                                                )));
                                  },
                                  child: const Text(
                                    'Forgot your password?',
                                    style: TextStyle(
                                      color: green,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_loginFormKey.currentState!
                                          .validate()) {
                                        EasyLoading.show();
                                        try {
                                          String phoneNumberSt =
                                              phoneNumberController.text;
                                          String password =
                                              passwordController.text;
                                          int? phoneNumInt =
                                              int.tryParse(phoneNumberSt);

                                          Map<String, dynamic> response =
                                              await loginUser(
                                                  phoneNumInt!, password);
                                          EasyLoading.dismiss();

                                          if (response['status'] == 'success' ||
                                              response['status'] ==
                                                  'subscription-failed') {
                                            APIService
                                                .getUserDetailsWithoutDialog(
                                                    response['data']['token']);
                                            // Successful login
                                            await storeTokenAndUser(
                                                response['data']['token'],
                                                response['data']['user'],
                                                response['data']['api_key'],
                                                response[
                                                    'isSubscriptionExpired']);
                                          } else if (response['status'] ==
                                                  'failed' &&
                                              response['message'] ==
                                                  'Validation Error!') {
                                            // Validation error, display error messages
                                            Map<String, dynamic> errors =
                                                response['data'];
                                            errors.forEach((field, messages) {
                                              // You can display these error messages to the user
                                            });
                                          } else if (response['status'] ==
                                                  'failed' &&
                                              response['message'] ==
                                                  'Invalid credentials') {
                                            // Invalid credentials error, display error message
                                            debugPrint('Invalid credentials');
                                            // You can display this error message to the user
                                          } else {
                                            // Handle other cases or unexpected responses
                                            debugPrint(
                                                'Unexpected response: $response');
                                          }
                                        } catch (e) {
                                          // Handle other errors
                                          Result.error(
                                              "Book list not available");
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(15.0),
                                      backgroundColor: green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: white,
                                        fontFamily: 'Roboto-Regular',
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account?",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      const SignUpPage()));
                                        },
                                        child: const Text('Register Now'))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> loginUser(
      int phoneNumber, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'YourApp/1.0',
      },
      body: jsonEncode({"mobile": phoneNumber, "password": password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const HomePage()),
      );
      Timer.periodic(const Duration(seconds: 1), (timer) {
        _localDatabase.clearTable();
        _localDatabase.fetchDataAndStoreLocally();

        if (timer.tick == 1) {
          timer.cancel();
          // Code to Run
        }
      });

      // Successful login
      final Map<String, dynamic> responseData = json.decode(response.body);
      // No need to show any dialog, just return the response data
      return responseData;
    } else {
      // Handle non-200 status codes
      debugPrint('Failed to login. Status code: ${response.statusCode}');
      // Prepare error response
      final Map<String, dynamic> errorResponse = {
        'status': 'failed',
        'message': 'Failed to login. Status code: ${response.statusCode}',
      };

      // Display error dialog based on status code
      switch (response.statusCode) {
        case 401:
          // Unauthorized
          errorResponse['message'] = 'Invalid credentials';
          break;
        case 403:
          // Forbidden
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData.containsKey('data')) {
            // Handle specific validation errors
            errorResponse['message'] = 'Validation Error!';
            // Construct a user-friendly message from the validation errors
            String errorMessage = '';
            responseData['data'].forEach((key, value) {
              errorMessage += '${value[0]}\n';
            });
            errorResponse['validationErrors'] = errorMessage;
          } else {
            errorResponse['message'] = 'Forbidden: ${responseData['message']}';
          }
          break;
        case 404:
          // Not Found
          errorResponse['message'] = 'User Not Found';
          break;
        default:
          // Handle other status codes
          errorResponse['message'] =
              'Failed to login. Status code: ${response.statusCode}';
          break;
      }

      // Display error dialog
      showApiResponseDialog(context, errorResponse);
      // Return the error response for further handling in the frontend
      return errorResponse;
    }
  }

  Future<void> storeTokenAndUser(String token, Map<String, dynamic> userData,
      String apiKey, int subscriptionExpired) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('subscriptionExpired', subscriptionExpired);
    await prefs.setString('token', token);
    await prefs.setString('user', userData.toString());
    await prefs.setString('auth-key', apiKey);
  }
}

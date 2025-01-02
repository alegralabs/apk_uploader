import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:newprobillapp/components/api_constants.dart';
import 'package:newprobillapp/components/color_constants.dart';
import 'package:newprobillapp/pages/reset_password.dart';
import 'package:newprobillapp/services/api_services.dart';

import 'package:newprobillapp/services/result.dart';
import 'package:pinput/pinput.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String smsType;
  const ForgotPasswordPage({super.key, required this.smsType});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final _otpFormKey = GlobalKey<FormState>();
  bool otpSent = false;

  bool _isPhoneNumberErrorVisible() {
    return phoneNumberController.text.isNotEmpty &&
        (phoneNumberController.text.length < 10 ||
            phoneNumberController.text.length > 10);
  }

  Future _verifyOtp(String otp, String phoneNumber) async {
    var token = await APIService.getToken();
    var authKey = await APIService.getXApiKey();
    EasyLoading.show(status: 'Verifying OTP');
    final response =
        await http.post(Uri.parse('$baseUrl/generate-verify-otp'), headers: {
      'Authorization': 'Bearer $token',
      'auth-key': '$authKey',
    }, body: {
      'type': 'verify-otp',
      'mobile': phoneNumber,
      'otp': otp
    });
    EasyLoading.dismiss();
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'OTP verified successfully');
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ResetPasswordPage(
                    phoneNumber: phoneNumber,
                  )));
    } else if (response.statusCode == 410) {
      Fluttertoast.showToast(
          msg: 'OTP Expired. Please press resend to get a new OTP.');
    } else {
      Fluttertoast.showToast(msg: 'Invalid OTP. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();

    super.dispose();
  }

  sendOtp(String phoneNumber) async {
    var token = await APIService.getToken();
    var authKey = await APIService.getXApiKey();
    print('button tapped');
    final response =
        await http.post(Uri.parse('$baseUrl/generate-verify-otp'), headers: {
      'Authorization': 'Bearer $token',
      'auth-key': '$authKey',
    }, body: {
      'mobile': phoneNumber,
      'type': 'send-otp',
      'sms_type': widget.smsType,
    });

    if (response.statusCode == 200) {
      setState(() {
        otpSent = true;
      });
      Fluttertoast.showToast(msg: 'OTP sent successfully');
    } else if (response.statusCode == 400) {
      Fluttertoast.showToast(
          msg: 'Could not find an account with this mobile number');
    }
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
        key: _otpFormKey,
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
                  'Reset Password',
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
                                  controller: phoneNumberController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: green,
                                    )),
                                    filled: true,
                                    fillColor: white,
                                    label: Text('Mobile Number'),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(7.0),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                if (_isPhoneNumberErrorVisible())
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      'Must be a 10-digit number',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 15),
                                Visibility(
                                  visible: otpSent,
                                  child: Center(
                                    child: Pinput(
                                      onChanged: (value) => setState(() {}),
                                      controller: otpController,
                                      focusedPinTheme: PinTheme(
                                        width: 50,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: green,
                                        ),
                                      ),
                                      length: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: otpSent
                                        ? () async {
                                            if (otpController.text.length ==
                                                6) {
                                              EasyLoading.show();
                                              try {
                                                _verifyOtp(otpController.text,
                                                    phoneNumberController.text);
                                                EasyLoading.dismiss();
                                              } catch (e) {
                                                Result.error(
                                                    "Book list not available");
                                              }
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'OTP has to be of 6 digits.');
                                            }
                                          }
                                        : () {
                                            if (_otpFormKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                sendOtp(
                                                    phoneNumberController.text);
                                              });
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(15.0),
                                      backgroundColor: otpSent
                                          ? otpController.text.length == 6
                                              ? green
                                              : Colors.grey
                                          : green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      otpSent ? 'Confirm' : 'Send OTP',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: white,
                                        fontFamily: 'Roboto-Regular',
                                      ),
                                    ),
                                  ),
                                ),
                                otpSent
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "OTP not recieved?",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                sendOtp(
                                                    phoneNumberController.text);
                                              },
                                              child: const Text('Resend'))
                                        ],
                                      )
                                    : const SizedBox.shrink(),
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
}

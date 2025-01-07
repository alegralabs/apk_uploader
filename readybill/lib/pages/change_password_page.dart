import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/pages/login_page.dart';
import 'package:readybill/pages/reset_password.dart';
import 'package:readybill/services/api_services.dart';
import 'package:readybill/services/global_internet_connection_handler.dart';
import 'package:readybill/services/result.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;

class ChangePasswordPage extends StatefulWidget {
  final String smsType;
  const ChangePasswordPage({super.key, required this.smsType});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
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
      resetPasswordModalBottomSheet();
      // Navigator.push(
      //     context,
      //     CupertinoPageRoute(
      //         builder: (context) => ResetPasswordPage(
      //               phoneNumber: phoneNumber,
      //             )));
    } else if (response.statusCode == 410) {
      Fluttertoast.showToast(
          msg: 'OTP Expired. Please press resend to get a new OTP.');
    } else {
      Fluttertoast.showToast(msg: 'Invalid OTP. Please try again.');
    }
  }

  void resetPassword() async {
    var token = await APIService.getToken();
    var authKey = await APIService.getXApiKey();
    var response =
        await http.post(Uri.parse("$baseUrl/update-password"), headers: {
      'Authorization': 'Bearer $token',
      'auth-key': '$authKey',
    }, body: {
      'mobile': phoneNumberController.text,
      'password': newPasswordController.text,
      'password_confirmation': confirmPasswordController.text
    });
    print(response.body);
    print(phoneNumberController.text);
    print(newPasswordController.text);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg:
              'Password reset successfully. Please log in with the neww password.');
      navigatorKey.currentState?.pushReplacement(
          CupertinoPageRoute(builder: (context) => const LoginPage()));
    }
  }

  resetPasswordModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Form(
          key: _passwordFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              TextFormField(
                cursorColor: green,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 8) {
                    return 'Length must be atleast 8 characters';
                  }
                  return null;
                },
                obscureText: true,
                controller: newPasswordController,
                decoration: customTfInputDecoration("Enter New Password"),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                  cursorColor: green,
                  validator: (value) {
                    if (newPasswordController.text != value) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  controller: confirmPasswordController,
                  keyboardType: TextInputType.number,
                  decoration: customTfInputDecoration("Confirm Password")),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  child: customElevatedButton("Confirm", green2, white, () {
                    if (_passwordFormKey.currentState!.validate()) {
                      resetPassword();
                    }
                  })),
            ],
          ),
        ),
      ),
    );
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
    return Scaffold(
      appBar: customAppBar("Change Password"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _otpFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                    "To change your password, we will need to send you an OTP in your registered mobile.\n\nClick Send OTP to confirm.\n\n"),
                TextFormField(
                    cursorColor: green2,
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
                    decoration: customTfInputDecoration("Mobile Number")),
                if (_isPhoneNumberErrorVisible())
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Must be a 10-digit number',
                      style: TextStyle(
                        color: red,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                Visibility(
                  visible: otpSent,
                  child: Center(
                    child: Pinput(
                      showCursor: true,
                      onChanged: (value) => setState(() {}),
                      controller: otpController,
                      focusedPinTheme: PinTheme(
                        width: 50,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: green2,
                        ),
                      ),
                      defaultPinTheme: PinTheme(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: darkGrey,
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
                            if (otpController.text.length == 6) {
                              EasyLoading.show();
                              try {
                                _verifyOtp(otpController.text,
                                    phoneNumberController.text);
                                EasyLoading.dismiss();
                              } catch (e) {
                                Result.error("Book list not available");
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'OTP has to be of 6 digits.');
                            }
                          }
                        : () {
                            if (_otpFormKey.currentState!.validate()) {
                              setState(() {
                                sendOtp(phoneNumberController.text);
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15.0),
                      backgroundColor: otpSent
                          ? otpController.text.length == 6
                              ? green2
                              : Colors.grey
                          : green2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "OTP not recieved?",
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                              onPressed: () {
                                sendOtp(phoneNumberController.text);
                              },
                              child: const Text('Resend'))
                        ],
                      )
                    : const SizedBox.shrink(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

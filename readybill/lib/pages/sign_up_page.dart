// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/pages/login_page.dart';
import 'package:readybill/pages/terms_and_conditions.dart';

import 'package:readybill/services/global_internet_connection_handler.dart';
import 'package:readybill/services/result.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? _selectedShopType = "grocery";
  XFile? logoImageFile;
  bool isPasswordObscure = true;
  bool isConfirmPasswordObscure = true;
  bool acceptTermsAndConditions = false;

  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController buisnessNameController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController gstinController = TextEditingController();
  FocusNode phoneNumberFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool tncError = false;

  @override
  void dispose() {
    mobileNumberController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    phoneNumberFocusNode.requestFocus();
  }

  Future<void> pickLogoImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      logoImageFile = image;
    });
  }

  Widget _buildMobileNumberTF() {
    return TextFormField(
      cursorColor: green,
      focusNode: phoneNumberFocusNode,
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
      controller: mobileNumberController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        errorStyle: TextStyle(color: red),
        prefixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "  +91  ",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: green,
        )),
        filled: true,
        fillColor: white,
        hintText: 'Mobile Number *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordTF() {
    // Flag to toggle password visibility
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      controller: passwordController,
      obscureText: isPasswordObscure,
      decoration: InputDecoration(
        errorStyle: TextStyle(color: red),
        filled: true,
        fillColor: white,
        hintText: 'Password *',
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
          color: green,
        )),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordObscure ? Icons.visibility_off : Icons.visibility,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          onPressed: () {
            setState(() {
              isPasswordObscure = !isPasswordObscure;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        } else if (value.length < 8) {
          return 'Password must be of atleast 8 characters';
        } else {
          return null;
        }
      },
    );
  }

  Widget _buildConfirmPasswordTF() {
    return TextFormField(
      obscureText: isConfirmPasswordObscure,
      textCapitalization: TextCapitalization.sentences,
      controller: confirmPasswordController,
      decoration: InputDecoration(
        errorStyle: const TextStyle(color: red),
        suffixIcon: IconButton(
          icon: Icon(
            isConfirmPasswordObscure ? Icons.visibility_off : Icons.visibility,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          onPressed: () {
            setState(() {
              isConfirmPasswordObscure = !isConfirmPasswordObscure;
            });
          },
        ),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
          color: green,
        )),
        filled: true,
        fillColor: white,
        hintText: 'Confirm Password *',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        } else if (value.length < 8) {
          return 'Password must be of atleast 8 characters';
        } else {
          return null;
        }
      },
    );
  }

  Widget _buildFullNameTF() {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      controller: fullNameController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        errorStyle: TextStyle(color: red),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: green,
        )),
        filled: true,
        fillColor: white,
        hintText: 'Your Name *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'FullName is required';
        }
        return null;
      },
    );
  }

  Widget _buildBuisnessNameTF() {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      controller: buisnessNameController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        errorStyle: TextStyle(color: red),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: green,
        )),
        filled: true,
        fillColor: white,
        hintText: 'Business Name *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Buisness Name is required';
        }
        return null;
      },
    );
  }

  Widget _buildEmailTF() {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        errorStyle: TextStyle(color: red),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: green,
        )),
        filled: true,
        fillColor: white,
        hintText: 'Email *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        return null;
      },
    );
  }

  Widget _buildAddressTF() {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      controller: addressController,
      keyboardType: TextInputType.text,
      style: const TextStyle(
        fontFamily: 'Roboto_Regular',
      ),
      decoration: const InputDecoration(
        errorStyle: TextStyle(color: red),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: green,
        )),
        filled: true,
        fillColor: white,
        hintText: 'Address *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Address is required';
        }
        return null;
      },
    );
  }

  Widget _buildShopTypeDropdown() {
    return DropdownButtonFormField<String>(
      hint: const Text(
        'Select Shop Type',
      ),
      value: _selectedShopType,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          _selectedShopType = newValue;
        });
      },
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: green,
        )),
        filled: true,
        fillColor: white,
        //  hintText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Shop Type is required';
        }
        return null;
      },
      items: <String>['grocery'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildSignUpBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          print('pressed');

          if (_formKey.currentState!.validate()) {
            if (acceptTermsAndConditions == false) {
              setState(() {
                tncError = true;
              });
            } else {
              submitData();
            }
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 5.0,
          backgroundColor: green,
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto_Regular',
          ),
        ),
      ),
    );
  }

  Widget _buildSignInText() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (context) =>
                  const LoginPage()), // Change to AddItemScreen()
        );
      },
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'I already have an account ',
              style: TextStyle(
                color: Color.fromARGB(255, 97, 97, 97),
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: Color.fromRGBO(221, 79, 60, 1),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGSTINTF() {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      controller: gstinController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        filled: true,
        fillColor: white,
        hintText: 'GSTIN',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLogoPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: pickLogoImage,
          child: const Text('Pick Logo Image'),
        ),
        const SizedBox(
            width: 10), // Add some space between the button and the thumbnail
        logoImageFile != null
            ? SizedBox(
                width: 50, // Set the width of the thumbnail
                height: 50, // Set the height of the thumbnail
                child: Image.file(File(logoImageFile!.path)),
              )
            : Container(), // If no image is selected, display an empty container
      ],
    );
  }

  Future<void> submitData() async {
    if (acceptTermsAndConditions == false) {
      setState(() {
        tncError = true;
      });
    }
    String sendOtpApiUrl = '$baseUrl/register/send-otp';

    var request = http.MultipartRequest('POST', Uri.parse(sendOtpApiUrl));

    // Add fields to the request
    request.fields['name'] = fullNameController.text;
    request.fields['business_name'] = buisnessNameController.text;
    request.fields['email'] = emailController.text;
    request.fields['mobile'] = mobileNumberController.text;
    request.fields['password'] = passwordController.text;
    request.fields['password_confirmation'] = confirmPasswordController.text;
    request.fields['address'] = addressController.text;
    request.fields['gstin'] = gstinController.text;
    request.fields['shop_type'] = _selectedShopType ?? '';
    request.fields['terms_n_conditions'] = acceptTermsAndConditions.toString();

    // Add logo if it's available
    if (logoImageFile != null) {
      var logoStream = http.ByteStream(logoImageFile!.openRead());
      var logoLength = await logoImageFile!.length();
      var logoMultipartFile = http.MultipartFile(
        'logo',
        logoStream,
        logoLength,
        filename: logoImageFile!.path.split('/').last,
      );
      request.files.add(logoMultipartFile);
    }

    // Send the request
    try {
      EasyLoading.show(status: 'Loading...');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print(responseBody);
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        showModalBottomSheet(
            context: context,
            builder: (context) => OtpModalBottomSheet(
                  phoneNumber: mobileNumberController.text,
                ));
      } else if (response.statusCode == 400) {
        Fluttertoast.showToast(
            msg:
                "The mobile number has already been taken. Please use a different number.");
      } else {
        Fluttertoast.showToast(
            msg:
                "There seems to be an issue at our end. Please try after some time.");
      }
      // Call the function to show the response dialog
    } catch (error) {
      Result.error("Book list not available");
    }
  }

  void showApiResponseDialog(
      BuildContext context, Map<String, dynamic> response) {
    String title;
    String content;

    // Determine title and content based on the response
    if (response['status'] == 'success') {
      title = "Registration Successful";
      content =
          "Token: ${response['data']['token']}\nUser ID: ${response['data']['user']['id']}";
    } else if (response['status'] == 'failed' &&
        response['message'] == 'Validation Error!') {
      title = "Validation Error";
      content = "Please check the following errors:\n";

      // Loop through validation errors
      Map<String, dynamic> errors = response['data'];
      errors.forEach((field, messages) {
        content += "$field: ${messages[0]}\n";
      });
    } else {
      title = "Unexpected Response";
      content = "An unexpected response was received. Please try again.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Alert'),
                content: const Text('Do You Want to Exit'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              );
            });
        if (value != null) {
          return Future.value();
        } else {
          return Future.value();
        }
      },
      child: Scaffold(
        backgroundColor: black,
        body: SizedBox(
          height: screenHeight,
          child: Stack(
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
                top: screenHeight * 0.30,
                left: screenWidth * 0.1,
                child: const Text(
                  'Register',
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
                bottom: screenHeight * 0.05,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        height: screenHeight * 0.55,
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Already have an account?",
                                        style: TextStyle(
                                            fontFamily: 'Roboto-Regular',
                                            color: white),
                                      ),
                                      const SizedBox(width: 5),
                                      InkWell(
                                        child: const Text(
                                          'Sign In',
                                          style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                              color: green),
                                        ),
                                        onTap: () => navigatorKey.currentState!
                                            .push(CupertinoPageRoute(
                                                builder: (context) =>
                                                    const LoginPage())),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  _buildMobileNumberTF(),
                                  const SizedBox(height: 15),
                                  _buildPasswordTF(),
                                  const SizedBox(height: 15),
                                  _buildConfirmPasswordTF(),
                                  const SizedBox(height: 15),
                                  _buildFullNameTF(),
                                  const SizedBox(height: 15),
                                  _buildBuisnessNameTF(),
                                  const SizedBox(height: 15),
                                  _buildEmailTF(),
                                  const SizedBox(height: 15),
                                  _buildAddressTF(),
                                  const SizedBox(height: 15),
                                  _buildGSTINTF(),
                                  const SizedBox(height: 15),
                                  _buildShopTypeDropdown(),
                                  // Added GSTIN field
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: customElevatedButton("Pick Logo",
                                        blue, white, pickLogoImage),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        side: WidgetStateBorderSide.resolveWith(
                                          (states) => const BorderSide(
                                              width: 2, color: white),
                                        ),
                                        value: acceptTermsAndConditions,
                                        onChanged: (value) => setState(() {
                                          acceptTermsAndConditions = value!;
                                        }),
                                      ),
                                      const Text(
                                        'I agree to all the',
                                        style: TextStyle(color: white),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          navigatorKey.currentState?.push(
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      const TermsAndConditionsPage()));
                                        },
                                        child: const Text(
                                          'Terms & Conditions',
                                          style: TextStyle(color: green),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                      visible: tncError,
                                      child: const Text(
                                        "Accept Terms and Conditions to proceed",
                                        style: TextStyle(color: red),
                                      )),
                                  // Added Logo Upload field
                                  _buildSignUpBtn(),
                                ],
                              ),
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

class OtpModalBottomSheet extends StatefulWidget {
  final String phoneNumber;

  const OtpModalBottomSheet({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpModalBottomSheet> createState() => _OtpModalBottomSheetState();
}

class _OtpModalBottomSheetState extends State<OtpModalBottomSheet> {
  TextEditingController otpController = TextEditingController();
  FocusNode otpFocusNode = FocusNode();

  void _verifyOtp() async {
    String url = "$baseUrl/register/verify-otp";
    EasyLoading.show(status: 'Verifying OTP...');
    final response = await http.post(Uri.parse(url),
        body: {"mobile": widget.phoneNumber, "otp": otpController.text});

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "OTP Verified. Your account has been created successfully");
      navigatorKey.currentState?.pushReplacement(
        CupertinoPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    super.initState();
    otpFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Column(
              children: [
                const Text(
                  "Enter the OTP",
                  style: TextStyle(
                      color: white,
                      fontSize: 26,
                      fontFamily: 'Roboto-Regular',
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Pinput(
                  focusNode: otpFocusNode,
                  onChanged: (value) => setState(() {}),
                  controller: otpController,
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: green,
                    ),
                  ),
                  length: 6,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print('pressed');
                      _verifyOtp();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      backgroundColor: green,
                      padding: const EdgeInsets.all(15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto-Regular',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

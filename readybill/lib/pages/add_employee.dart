// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:readybill/components/api_constants.dart';

import 'package:readybill/components/bottom_navigation_bar.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/sidebar.dart';

import 'package:readybill/pages/view_employee.dart';
import 'package:readybill/services/api_services.dart';
import 'package:readybill/services/global_internet_connection_handler.dart';
import 'package:readybill/services/result.dart';

class EmployeeSignUpPage extends StatefulWidget {
  const EmployeeSignUpPage({super.key});

  @override
  State<EmployeeSignUpPage> createState() => _EmployeeSignUpPageState();
}

class _EmployeeSignUpPageState extends State<EmployeeSignUpPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  int _selectedIndex = 3;
  bool isObscureConfirm = true;
  bool isObscure = true;
  File? selectedImageFile;

  Future<void> submitData() async {
    EasyLoading.show(status: 'Loading...');
    var token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();
    String apiUrl = '$baseUrl/add-new-user';
    // Prepare the request headers
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'auth-key': '$apiKey' // Replace token with your actual token
    };

    // Prepare the request body
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll(headers);

    // Add fields to the request
    request.fields['name'] = nameController.text;
    request.fields['mobile'] = mobileController.text;
    request.fields['password'] = passwordController.text;
    request.fields['password_confirmation'] = confirmPasswordController.text;
    request.fields['address'] = addressController.text;
    if (selectedImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        selectedImageFile!.path,
      ));
    }
    try {
      EasyLoading.show(status: 'loading...');
      var response = await request.send();

      print("response status code: ${response.statusCode}");

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print(responseBody);
        // showApiResponseDialog(context, jsonDecode(responseBody));
        Fluttertoast.showToast(msg: 'User added successfully');
        navigatorKey.currentState?.pushReplacement(
          CupertinoPageRoute(builder: (_) => const EmployeeListPage()),
        ); // Navigate to the login screen();
      } else {
        // Request successful
        var responseBody = await response.stream.bytesToString();
        // Decode the response body
        var decodedResponse = jsonDecode(responseBody);
        print(decodedResponse);
        String messageMobile =
            decodedResponse['data']['mobile']?.join(', ') ?? '';
        String messagePassword =
            decodedResponse['data']['password']?.join(', ') ?? '';
        String messageName = decodedResponse['data']['name']?.join(', ') ?? '';
        String messageAddress =
            decodedResponse['data']['address']?.join(', ') ?? '';
        String finalMessage =
            '$messageName\n$messageMobile\n$messagePassword\n$messageAddress';
        callAlert(finalMessage);

        print(jsonDecode(responseBody));
        Result.error("Book list not available");
      }
    } catch (error) {
      Result.error("Book list not available");
    } finally {
      EasyLoading
          .dismiss(); // Dismiss the loading indicator regardless of the request outcome
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isKeyboardVisible
          ? null
          : FloatingActionButton(
              backgroundColor: green2,
              foregroundColor: black,
              shape: const CircleBorder(),
              child: const Icon(Icons.check),
              onPressed: () {
                if (mobileController.text == '' ||
                    nameController.text == '' ||
                    passwordController.text == '' ||
                    confirmPasswordController.text == '' ||
                    addressController.text == '') {
                  callAlert("all fields are required");
                } else {
                  submitData();
                }
              },
            ),
      drawer: const Drawer(
        child: Sidebar(),
      ),
      appBar: customAppBar("Add Employee"),
      bottomNavigationBar: CustomNavigationBar(
        onItemSelected: (index) {
          // Handle navigation item selection
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 30.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: [
                          InkWell(
                            onTap: pickLogoImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: green2,
                              foregroundImage: selectedImageFile != null
                                  ? FileImage(selectedImageFile!)
                                  : (const AssetImage("assets/user.png")),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: green2,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                      _buildTF(
                          "Name", nameController, TextInputType.text, false),
                      const SizedBox(height: 10.0),
                      _buildTF("Mobile", mobileController, TextInputType.phone,
                          false),
                      const SizedBox(height: 10.0),
                      _buildTF("Password", passwordController,
                          TextInputType.text, true),
                      const SizedBox(height: 10.0),
                      _buildTF("Confirm Password", confirmPasswordController,
                          TextInputType.text, false),
                      const SizedBox(height: 10.0),
                      _buildTF("Address", addressController, TextInputType.text,
                          false),
                      const SizedBox(height: 40.0),
                      // _buildSignUpBtn(),
                      const SizedBox(height: 10.0),
                      // _buildSignInText(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTF(String hintText, TextEditingController controller,
      TextInputType keyboardType, bool isObscure) {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: customTfInputDecoration(hintText),
        obscureText: isObscure,
      ),
    );
  }

  Future<void> pickLogoImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImageFile = File(image.path);
      });
    }
  }

  callAlert(String message) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return customAlertBox(
            title: "Alert",
            content: message,
            actions: [
              customElevatedButton("OK", green2, white, () {
                  navigatorKey.currentState?.pop();
                }),
            ],
          );
        });
  }
}

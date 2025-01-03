// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:http/http.dart' as http;
import 'package:newprobillapp/components/api_constants.dart';
import 'package:newprobillapp/components/bottom_navigation_bar.dart';
import 'package:newprobillapp/components/sidebar.dart';
import 'package:newprobillapp/services/api_services.dart';
import 'package:newprobillapp/services/result.dart';

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

    try {
      EasyLoading.show(status: 'loading...');
      var response = await request.send();

      print("response status code: ${response.statusCode}");

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print(responseBody);
        showApiResponseDialog(context, jsonDecode(responseBody));
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

  void showApiResponseDialog(
      BuildContext context, Map<String, dynamic> response) {
    String title;
    String content;

    // Determine title and content based on the response
    if (response['status'] == 'success') {
      title = "Success";
      content = response['message'];
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
      title = "Error";
      content = response['message'] ?? "An unexpected error occurred";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff28a745),
        foregroundColor: Colors.white,
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
      drawer: const Sidebar(),
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: const Text(
          'Add Employee',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: const Color.fromRGBO(243, 203, 71, 1),
      ),
      backgroundColor: const Color.fromRGBO(246, 247, 255, 1),
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
              // SizedBox(
              //   height: double.infinity,
              //   width: double.infinity,
              //   child: ColorFiltered(
              //     colorFilter: ColorFilter.mode(
              //       Colors.black.withOpacity(0.5),
              //       BlendMode.darken,
              //     ),
              //   ),
              // ),
              SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 60.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 10.0),
                      // ElevatedButton(
                      //   child: const Text("View User"),
                      //   onPressed: () {
                      //     Navigator.pushReplacement(
                      //       context,
                      //       CupertinoPageRoute(
                      //           builder: (context) => const SubUserListPage()),
                      //     );
                      //   },
                      // ),
                      const SizedBox(height: 10.0),
                      _buildNameTF(),
                      _buildMobileTF(),
                      _buildPasswordTF(),
                      _buildConfirmPasswordTF(),
                      _buildAddressTF(),
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

  Widget _buildNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: nameController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.person,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              hintText: 'Name',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: mobileController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.phone,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              hintText: 'Mobile',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    // Flag to toggle password visibility
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10.0),
        TextField(
          controller: passwordController,
          obscureText: isObscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.only(top: 14.0),
            prefixIcon: const Icon(
              Icons.lock,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            hintText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility : Icons.visibility_off,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              onPressed: () {
                // Toggle password visibility
                setState(() {
                  isObscure = !isObscure;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: confirmPasswordController,
            obscureText: isObscureConfirm,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.lock,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              hintText: 'Confirm Password',
              suffixIcon: IconButton(
                icon: Icon(
                  isObscureConfirm ? Icons.visibility : Icons.visibility_off,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () {
                  // Toggle password visibility
                  isObscureConfirm = !isObscureConfirm;
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: addressController,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: Color.fromARGB(255, 7, 7, 7),
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.location_on,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              hintText: 'Address',
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildSignUpBtn() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 25.0),
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       onPressed: () {
  //         if (mobileController.text == '' ||
  //             nameController.text == '' ||
  //             passwordController.text == '' ||
  //             confirmPasswordController.text == '' ||
  //             addressController.text == '') {
  //           callAlert("all fields are required");
  //         } else {
  //           submitData();
  //         }
  //       },
  //       style: ElevatedButton.styleFrom(
  //         elevation: 5.0,
  //         backgroundColor: const Color(0xff28a745),
  //         padding: const EdgeInsets.all(15.0),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(0),
  //         ),
  //       ),
  //       child: const Text(
  //         'Add User',
  //         style: TextStyle(
  //           color: Colors.white,
  //           letterSpacing: 1.5,
  //           fontSize: 18.0,
  //           fontWeight: FontWeight.bold,
  //           fontFamily: 'OpenSans',
  //         ),
  //       ),
  //     ),
  //   );
  // }

  callAlert(String message) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:readybill/components/api_constants.dart';

import 'package:readybill/components/custom_components.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/services/api_services.dart';

String userDetailsAPI = "$baseUrl/user-detail";

class UserDetail {
  final int id;
  final String name;

  final String email;
  final String mobile;
  final String address;
  final String shopType;
  final String gstin;
  final String logo;
  final String businessName;
  final String entityId;

  UserDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.shopType,
    required this.gstin,
    required this.logo,
    required this.businessName,
    required this.entityId,
  });
}

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  late TextEditingController nameController;
  late TextEditingController userNameController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController shopTypeController;
  late TextEditingController gstinController;
  late TextEditingController businessNameController;
  late TextEditingController entityIdController;

  UserDetail? userDetail;
  XFile? logoImageFile;
  String? logo;
  File? selectedImageFile;
  @override
  void initState() {
    super.initState();
    getUserDetail();
  }

  _submitData() async {
    var token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/update-profile'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'auth-key': '$apiKey',
      });

      // Add text fields
      request.fields.addAll({
        'user_id': userDetail!.id.toString(),
        'name': nameController.text,
        'email': emailController.text,
        'mobile': phoneController.text,
        'address': addressController.text,
        'shop_type': shopTypeController.text,
        'gstin': gstinController.text,
        'isLogoDelete': '0',
      });

      // Add logo file if exists
      if (logoImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'logo',
            logoImageFile!.path,
          ),
        );
      }
      EasyLoading.show(status: 'Updating...');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      EasyLoading.dismiss();
      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("Profile updated successfully."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 413) {
        Fluttertoast.showToast(
            msg: 'Image too large. Please select a smaller image.');
      } else {
        // Handle error response
        showDialog(
          context: context,
          builder: (BuildContext context) {
            print(response.body);
            return AlertDialog(
              title: const Text("Error"),
              content:
                  Text("Failed to update profile. ${response.reasonPhrase}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle exception
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("An error occurred while updating profile. $e"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> getUserDetail() async {
    String? token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();
    final response = await http.get(
      Uri.parse(userDetailsAPI),
      headers: {
        'Authorization': 'Bearer $token',
        'auth-key': '$apiKey',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      //print(response.body);
      final userData = jsonData['data'];
      logo = jsonData['logo'];
      setState(() {
        userDetail = UserDetail(
          id: userData['user_id'],
          name: userData['name'],
          //   username: userData['username'],
          email: userData['details']['email'],
          mobile: userData['mobile'],
          address: userData['details']['address'],
          shopType: userData['details']['shop_type'],
          gstin: userData['details']['gstin'],
          logo: userData['logo'],
          businessName: userData['details']['business_name'],

          entityId: jsonData['entity_id'],
        );
      });
      nameController = TextEditingController(text: userDetail!.name);

      emailController = TextEditingController(text: userDetail!.email);
      phoneController = TextEditingController(text: userDetail!.mobile);
      addressController = TextEditingController(text: userDetail!.address);
      shopTypeController = TextEditingController(text: userDetail!.shopType);
      gstinController = TextEditingController(text: userDetail!.gstin);
      businessNameController =
          TextEditingController(text: userDetail!.businessName);
      entityIdController = TextEditingController(text: userDetail!.entityId);
    } else {
      throw Exception('Failed to load user detail');
    }
  }

  Widget textFieldCustom(TextEditingController controller, bool obscureText,
      String hintText, bool readOnly) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      decoration: readOnly ? null : customTfInputDecoration(hintText),
    );
  }

  Future<void> pickLogoImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImageFile = File(image.path);
        logoImageFile = image; // Add this line to store the XFile
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  backgroundColor: const Color.fromRGBO(246, 247, 255, 1),
      appBar: customAppBar('Account Details'),
      body: userDetail == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        onTap: pickLogoImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: green2,
                          foregroundImage: selectedImageFile != null
                              ? FileImage(selectedImageFile!)
                              : (logo != ''
                                  ? NetworkImage(logo!) as ImageProvider
                                  : const AssetImage("assets/user.png")),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: green2,
                            border: Border.all(color: Colors.white, width: 2),
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
                  const SizedBox(height: 20.0),
                  textFieldCustom(entityIdController, false, "Entity ID", true),
                  const SizedBox(height: 10.0),
                  textFieldCustom(nameController, false, 'Name', false),
                  const SizedBox(height: 10.0),
                  textFieldCustom(
                      businessNameController, false, 'Business Name', true),
                  const SizedBox(height: 10.0),
                  textFieldCustom(emailController, false, 'Email', true),
                  const SizedBox(height: 10.0),
                  textFieldCustom(phoneController, false, 'Mobile', true),
                  const SizedBox(height: 10.0),
                  textFieldCustom(addressController, false, 'Address', false),
                  const SizedBox(height: 10.0),
                  textFieldCustom(
                      shopTypeController, false, 'Shop Type', false),
                  const SizedBox(height: 10.0),
                  textFieldCustom(
                      gstinController, false, 'GSTIN Number', false),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: customElevatedButton(
                        "Update Changes", blue, white, _submitData),
                  ),
                ],
              ),
            ),
    );
  }
}

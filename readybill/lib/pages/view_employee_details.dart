import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/pages/view_employee.dart';
import 'package:readybill/services/api_services.dart';
import 'package:http/http.dart' as http;

class ViewEmployeeDetails extends StatefulWidget {
  final Employee user;

  ViewEmployeeDetails({super.key, required this.user});

  @override
  State<ViewEmployeeDetails> createState() => _ViewEmployeeDetailsState();
}

class _ViewEmployeeDetailsState extends State<ViewEmployeeDetails> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  XFile? profilePhoto;
  @override
  void initState() {
    super.initState();
    profilePhoto = const Image(image: AssetImage("assets/user.png")) as XFile;
  }

  Future<void> updateUserDetails() async {
    try {
      String? token = await APIService.getToken();
      String? apiKey = await APIService.getXApiKey();
      EasyLoading.show(status: 'Updating...');
      var response = await http.post(Uri.parse('$baseUrl/update-sub-users'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'auth-key': '$apiKey',
          },
          body: jsonEncode({
            //'photo': photoUrl,
            'name': nameController.text,
            'address': addressController.text,
            'mobile': mobileController.text,
            'id': widget.user.id,
          }));
      EasyLoading.dismiss();
      if (response.statusCode == 201) {
        var jsonData = jsonDecode(response.body);
        Fluttertoast.showToast(msg: jsonData['message'].toString());
        Navigator.push(context, CupertinoPageRoute(builder: (context) {
          return const EmployeeListPage();
        }));
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  buildTextField(String label, TextEditingController controller) {
    return TextField(
      decoration: customTfInputDecoration(label),
      controller: controller,
    );
  }

  Future<void> pickLogoImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      profilePhoto = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = widget.user.name;
    mobileController.text = widget.user.mobile;
    addressController.text = widget.user.address;
    String photoUrl = widget.user.photo;

    return Scaffold(
      appBar: customAppBar("Employee Details"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => pickLogoImage(),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: green2,
                foregroundImage: photoUrl == 'N/A'
                    ? const AssetImage("assets/user.png")
                    : NetworkImage(photoUrl),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            buildTextField("Enter Name", nameController),
            const SizedBox(
              height: 20,
            ),
            buildTextField("Enter Mobile Number", mobileController),
            const SizedBox(
              height: 20,
            ),
            buildTextField("Enter Address", addressController),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                child: customElevatedButton(
                    "Update", green2, white, updateUserDetails)),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newprobillapp/components/api_constants.dart';
import 'package:newprobillapp/pages/view_employee.dart';
import 'package:newprobillapp/services/api_services.dart';
import 'package:http/http.dart' as http;

class ViewEmployeeDetails extends StatelessWidget {
  final Employee user;

  ViewEmployeeDetails({super.key, required this.user});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = user.name;
    mobileController.text = user.mobile;
    addressController.text = user.address;

    Future<void> updateUserDetails() async {
      try {
        String? token = await APIService.getToken();
        String? apiKey = await APIService.getXApiKey();
        EasyLoading.show(status: 'Updating...');
        var response = await http.post(
          Uri.parse(
              '$baseUrl/update-sub-users?id=${user.id}&name=${nameController.text}&address=${addressController.text}&mobile=${mobileController.text}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'auth-key': '$apiKey',
          },
        );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee Details',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: const Color.fromRGBO(243, 203, 71, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter Name',
                border: OutlineInputBorder(),
              ),
              controller: nameController,
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter Mobile Number',
                border: OutlineInputBorder(),
              ),
              controller: mobileController,
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter Address',
                border: OutlineInputBorder(),
              ),
              controller: addressController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    //backgroundColor: Color(const Color(0xff28a745))
                    ),
                child: const Text('Update Employee Details'),
                onPressed: () {
                  // Update user details
                  updateUserDetails();
                }),
          ],
        ),
      ),
    );
  }
}

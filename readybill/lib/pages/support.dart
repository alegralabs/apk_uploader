import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/bottom_navigation_bar.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/services/api_services.dart';
import 'package:http/http.dart' as http;

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  TextEditingController questionTitleController = TextEditingController();
  FocusNode questionTitleFocusNode = FocusNode();
  TextEditingController questionBodyController = TextEditingController();
  FocusNode questionBodyFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? file;

  final List<Item> _items = List<Item>.generate(6, (index) {
    return Item(
        title: "Support Title $index", subTitle: "Support SubTitle $index");
  });

  submitQuestion() async {
    var apiKey = await APIService.getXApiKey();
    var token = await APIService.getToken();
    EasyLoading.show(status: 'Sending question...');

    var request =
        http.MultipartRequest('POST', Uri.parse("$baseUrl/create-query"))
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['auth-key'] = '$apiKey';
    request.fields['title'] = questionTitleController.text;
    request.fields['description'] = questionBodyController.text;

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'attachment',
        file!.path,
      ));
    }
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Question submitted successfully");
      questionTitleController.clear();
      questionBodyController.clear();
      file = null;
    } else {
      Fluttertoast.showToast(msg: "Failed to submit question");
    }
  }

  uploadAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpeg',
        'jpg',
        'gif',
        'bmp',
        'png',
        'txt',
        'rtf',
        'doc',
        'docx',
        'pdf'
      ],
    );

    if (result != null) {
      File selectedFile = File(result.files.single.path!);

      if (await selectedFile.length() < 20 * 1024 * 1024) {
        // Update the file in the parent widget's state
        setState(() {
          file = selectedFile;
        });

        // If this method is called within the bottom sheet, trigger a rebuild
        Navigator.of(context).pop();
        questionModalBottomSheet(context);
      } else {
        Fluttertoast.showToast(
            msg: "File size too large. Please try another file.");
      }
    }
  }

  questionModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text("ENTER YOUR QUESTION",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Title: ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        focusNode: questionTitleFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            questionTitleFocusNode.requestFocus();
                            return "Please enter a title";
                          }
                          return null;
                        },
                        controller: questionTitleController,
                        decoration: customTfInputDecoration("Title"),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Details: ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        focusNode: questionBodyFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            questionBodyFocusNode.requestFocus();
                            return "Please enter the details";
                          }
                          return null;
                        },
                        controller: questionBodyController,
                        decoration: customTfInputDecoration("Details"),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: customElevatedButton(
                                "Add Attachment", blue, white, () {
                              uploadAttachment();
                              // Force bottom sheet to rebuild
                              setState(() {});
                            }),
                          ),
                          if (file != null) ...[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                file!.path.split('/').last,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(color: Colors.blue),
                                softWrap: true,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  file = null;
                                });
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: red,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.maxFinite,
                        child:
                            customElevatedButton("Submit", green2, white, () {
                          if (_formKey.currentState!.validate()) {
                            submitQuestion();
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Support"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "FAQ:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: () {
                      questionModalBottomSheet(context);
                    },
                    child: const Text(
                      "Ask us a question",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: blue,
                      ),
                    ))
              ],
            ),
            const SizedBox(height: 16.0),
            SingleChildScrollView(
              child: ExpansionPanelList(
                elevation: 0,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    for (int i = 0; i < _items.length; i++) {
                      _items[i].isExpanded = false;
                    }

                    if (isExpanded) {
                      _items[index].isExpanded = true;
                    }
                  });
                },
                children: _items.map<ExpansionPanel>((Item item) {
                  return ExpansionPanel(
                      backgroundColor: darkGrey,
                      canTapOnHeader: true,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(title: Text(item.title));
                      },
                      body: ListTile(
                        title: Text(item.subTitle),
                        tileColor: lightGrey,
                      ),
                      isExpanded: item.isExpanded);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class Item {
  String title;
  String subTitle;
  bool isExpanded;
  Item({
    required this.title,
    required this.subTitle,
    this.isExpanded = false,
  });
}

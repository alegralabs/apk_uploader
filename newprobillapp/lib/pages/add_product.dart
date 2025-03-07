// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:newprobillapp/components/api_constants.dart';

import 'package:newprobillapp/components/bottom_navigation_bar.dart';
import 'package:newprobillapp/components/custom_components.dart';
import 'package:newprobillapp/components/color_constants.dart';
import 'package:newprobillapp/components/sidebar.dart';
import 'package:newprobillapp/pages/home_page.dart';
import 'package:newprobillapp/pages/login_page.dart';
import 'package:newprobillapp/services/api_services.dart';
// import 'package:newprobillapp/services/local_database.dart';
import 'package:newprobillapp/services/local_database_2.dart';
import 'package:newprobillapp/services/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

String uploadExcelAPI = '$baseUrl/preview/excel';
String downloadExcelAPI = '$baseUrl/export';

class AddInventoryService {
  static Future<String?> uploadXLS(File file) async {
    var token = await APIService.getToken();
    var uri = Uri.parse(uploadExcelAPI);
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return responseData;
    } else {
      // Log the response body
      Result.error("Book list not available");
      return null;
    }
  }

  static Future<String?> downloadXLS() async {
    var token = await APIService.getToken();

    var response = await http.get(
      Uri.parse(downloadExcelAPI),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      return responseData['file'];
    } else {
      return null;
    }
  }
}

class AddInventory extends StatefulWidget {
  const AddInventory({super.key});

  @override
  State<AddInventory> createState() => _AddInventoryState();
}

class _AddInventoryState extends State<AddInventory> {
  // Dummy data for the unit dropdown
  List<String> fullUnits = [
    'Full Unit',
    'Bags',
    'Bottle',
    'Box',
    'Bundle',
    'Can',
    'Cartoon',
    'Gram',
    'Kilogram',
    'Litre',
    'Meter',
    'Millilitre',
    'Number',
    'Pack',
    'Pair',
    'Piece',
    'Roll',
    'Square Feet',
    'Square Meter'
  ];

  List<String> shortUnits = [
    'Short Unit *',
    'BAG',
    'BTL',
    'BOX',
    'BDL',
    'CAN',
    'CTN',
    'GM',
    'KG',
    'LTR',
    'MTR',
    'ML',
    'NUM',
    'PCK',
    'PRS',
    'PCS',
    'ROL',
    'SQF',
    'SQM'
  ];

  List<Widget> taxRateRows = [];
  List<Key> taxRateRowKeys = [];
  TextEditingController itemNameValueController = TextEditingController();
  TextEditingController mrpValueController = TextEditingController();
  TextEditingController salePriceValueController = TextEditingController();
  TextEditingController stockQuantityValueController = TextEditingController();
  TextEditingController codeHSNSACvalueController = TextEditingController();
  TextEditingController rateOneValueController = TextEditingController();
  TextEditingController rateTwoValueController = TextEditingController();

  Map<int, String> rateControllers = {};
  Map<int, String> taxControllers = {};

  String? fullUnitDropdownValue;
  String? shortUnitDropdownValue;
  int _selectedIndex = 2;
  bool maintainMRP = false;
  bool maintainStock = false;
  bool showHSNSACCode = false;
  bool isLoading = false;

  String? token;

  @override
  void initState() {
    super.initState();
    var key = GlobalKey();
    taxRateRowKeys.add(key);
    taxRateRows.add(_buildTaxRateRow(key, 0));
    // Initialize the taxRateRows list with the first row

    rateControllers[0] = "";
    taxControllers[0] = "GST";
    _initializeData();
  }

  Future<void> _handleUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String? response = await AddInventoryService.uploadXLS(file);
      if (response != null) {
        // Show response in a dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Upload Response'),
              content: Text(response),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Show error message in a dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Upload Error'),
              content: const Text('Failed to upload the file.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _handleDownload() async {
    const url = '$baseUrl/storage/media/exported_data.xlsx';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Directory? directory;

      directory = Directory('/storage/emulated/0/Download');

      if (directory != null) {
        final filePath = '${directory.path}/exported_data.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Download Success'),
              content: Text('File downloaded successfully to $filePath'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Download Error'),
              content: const Text('Failed to access external storage.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Download Error'),
            content: const Text('Failed to download the file.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildCombinedDropdown(
      List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xffbfbfbf),
            width: 3.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: green2,
            width: 3.0,
          ),
        ),
      ),
      hint: const Text(
        'Full Unit (Short Unit)' ' *',
      ),
      value: fullUnitDropdownValue == null
          ? null
          : '$fullUnitDropdownValue ($shortUnitDropdownValue)', // Initial value
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _initializeData() async {
    token = await APIService.getToken();
    APIService.getUserDetails(token, _showFailedDialog);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _fetchUserPreferences());
  }

  Future<void> _fetchUserPreferences() async {
    setState(() {
      isLoading = true;
    });
    var token = await APIService.getToken();
    // Make API call to fetch user preferences
    const String apiUrl = '$baseUrl/user-preferences';
    var apiKey = await APIService.getXApiKey();
    final response = await http.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $token',
      'auth-key': '$apiKey',
    });
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final preferencesData = jsonData['data'];

      setState(() {
        maintainMRP = preferencesData['preference_mrp'] == 1 ? true : false;
        maintainStock =
            preferencesData['preference_quantity'] == 1 ? true : false;
        showHSNSACCode = preferencesData['preference_hsn'] == 1 ? true : false;
      });
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('An error occurred. Please login and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Redirect to login page
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  Future<void> returnToLastScreen() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _selectedIndex = 0;
        // Navigate to NextPage when user tries to pop MyHomePage
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
        // Return false to prevent popping the current route
        return;
      },
      child: Scaffold(
        drawer: const Drawer(
          child: Sidebar(),
        ),
        backgroundColor: const Color.fromRGBO(246, 247, 255, 1),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            submitData();
          },
          backgroundColor: const Color(0xff28a745),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.check),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: customAppBar("Add Product"),
        bottomNavigationBar: CustomNavigationBar(
          onItemSelected: (index) {
            // Handle navigation item selection
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedIndex: _selectedIndex,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(), // Show loading indicator
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            customElevatedButton(
                                "Upload", blue, white, _handleUpload),
                            const SizedBox(width: 10),
                            customElevatedButton(
                                "Download", green2, white, _handleDownload)
                          ],
                        ),
                      ),
                      // Item Name Input Box
                      const SizedBox(height: 15.0),
                      _buildInputBox(' Item Name', itemNameValueController,
                          (value) {
                        setState(() {
                          itemNameValueController.text =
                              value; // Update the itemNameValue
                        });
                      }),

                      const SizedBox(height: 20.0),
                      // Quantity in Stock
                      Row(children: [
                        Expanded(
                          child: _buildCombinedDropdown(
                              fullUnits
                                  .map((unit) =>
                                      '$unit (${shortUnits[fullUnits.indexOf(unit)]})')
                                  .toList(), (value) {
                            // Split the selected value into full unit and short unit
                            List<String> units = value!.split(' (');
                            String fullUnit = units[0];
                            String shortUnit =
                                units[1].substring(0, units[1].length - 1);
                            setState(() {
                              fullUnitDropdownValue =
                                  fullUnit; // Update the fullUnitDropdownValue
                              shortUnitDropdownValue =
                                  shortUnit; // Update the shortUnitDropdownValue
                            });
                          }),
                        )
                      ]),

                      const SizedBox(height: 20.0),

                      // Sale Price Input Box
                      Row(
                        children: [
                          Flexible(
                            child: Visibility(
                              visible: maintainMRP,
                              child: _buildInputBox(' MRP', mrpValueController,
                                  (value) {
                                setState(() {
                                  mrpValueController.text =
                                      value; // Update the mrpValue
                                });
                              }, isNumeric: true),
                            ),
                          ),
                          SizedBox(
                              width: maintainMRP
                                  ? 16.0
                                  : 0), // Add spacing if MRP is visible
                          Flexible(
                            // Use Flexible for salePriceValue as well
                            child: _buildInputBox(
                                ' Sale price: Rs.', salePriceValueController,
                                (value) {
                              setState(() {
                                salePriceValueController.text =
                                    value; // Update the itemNameValue
                              });
                            }, isNumeric: true),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16.0),
                      Visibility(
                        visible: maintainStock,
                        child: _buildInputBox(
                            ' Stock Quantity', stockQuantityValueController,
                            (value) {
                          setState(() {
                            stockQuantityValueController.text =
                                value; // Update the stockValue
                          });
                        }, isNumeric: true),
                      ),
                      const SizedBox(height: 16.0),
                      Visibility(
                        visible: showHSNSACCode,
                        child: _buildInputBox(
                            ' HSN/ SAC Code', codeHSNSACvalueController,
                            (value) {
                          setState(() {
                            codeHSNSACvalueController.text =
                                value; // Update the stockValue
                          });
                        }, isNumeric: true),
                      ),

                      // new emplementation

                      const SizedBox(height: 20.0),

                      Column(
                        children: [
                          for (int i = 0; i < taxRateRows.length; i++)
                            Column(
                              children: [
                                taxRateRows[i],
                                const SizedBox(height: 8.0),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInputBox(String hintText, TextEditingController textControllers,
      void Function(String) updateIdentifier,
      {bool isNumeric = false}) {
    return TextField(
      controller: textControllers,
      decoration: customTfInputDecoration("$hintText *"),
      keyboardType: isNumeric
          ? TextInputType.number
          : TextInputType.text, // Set keyboardType based on isNumeric flag
      onChanged: (value) {
        updateIdentifier(
            value); // Call the callback function to update the identifier
      },
    );
  }

// Function to submit data
  void submitData() async {
    if (token == null || token!.isEmpty) {
      return;
    }

    

    Map<String, dynamic> postData = {
      'item_name': itemNameValueController.text,
      'quantity': int.tryParse(stockQuantityValueController.text),
      'sale_price': int.tryParse(salePriceValueController.text),
      'full_unit': fullUnitDropdownValue,
      'short_unit': shortUnitDropdownValue,
      'mrp': mrpValueController.text, // Add mrp
      'hsn': codeHSNSACvalueController.text,
    };

    // for(var value in taxControllers.values){
    taxControllers.forEach((index, value) {
      index = index + 1;
      postData['tax$index'] = value;
    });
   

    postData['rate1'] = rateOneValueController.text;
    postData['rate2'] = rateTwoValueController.text;
    var apiKey = await APIService.getXApiKey();
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/add-item'),
        body: jsonEncode(postData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'auth-key': '$apiKey',
        },
      );
      print("response: ${response.body}");
      if (response.statusCode == 200) {
        LocalDatabase2.instance.clearTable();
        LocalDatabase2.instance.fetchDataAndStoreLocally();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("Item added successfully."),
              actions: [
                TextButton(
                  onPressed: () {
                    // Clear input fields
                    fullUnitDropdownValue = fullUnits[0];
                    shortUnitDropdownValue = shortUnits[0];
                    // taxControllers.clear();
                    rateControllers.clear();
                    taxRateRows.clear();
                    taxRateRowKeys.clear();
                    var key = GlobalKey();
                    taxRateRowKeys.add(key);
                    taxRateRows.add(_buildTaxRateRow(key, 0));
                    itemNameValueController.clear();
                    mrpValueController.clear();
                    salePriceValueController.clear();
                    stockQuantityValueController.clear();
                    codeHSNSACvalueController.clear();
                    rateOneValueController.clear();
                    rateTwoValueController.clear();
                    setState(() {
                      LocalDatabase2.instance.clearTable();
                      LocalDatabase2.instance.fetchDataAndStoreLocally();
                    });
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 401) {
        Result.error("Book list not available");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Unauthorized"),
              content: const Text("Token missing or unauthorized."),
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
      } else {
        var errorData = jsonDecode(response.body);
        Result.error("Book list not available");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text("Error: ${errorData['message']}"),
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
    } catch (error) {
      Result.error("Book list not available");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Error: $error"),
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

  void _showFailedDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Failed to Fetch User Details"),
          content:
              const Text("Unable to fetch user details. Please login again."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (context) =>
                          const LoginPage()), // Change to AddItemScreen()
                );
              },
              child: const Text("Login"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaxRateRow(Key key, int index) {
    bool isFirstRow = index == 0;
    bool isMaxRowsReached = taxRateRows.length >= 2;
    return Row(
      key: key,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
              value: taxControllers[index] ?? 'GST', // Provide a default value
              onChanged: (String? value) {
                setState(() {
                  taxControllers[index] = value!;
                });
              },
              items: const [
                DropdownMenuItem<String>(
                  value: 'GST',
                  child: Text('GST'),
                ),
                DropdownMenuItem<String>(
                  value: 'SASS',
                  child: Text('SASS'),
                ),
              ],
              hint: const Text('Select Tax'),
              decoration: customTfInputDecoration("Select Tax")),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: TextField(
              controller:
                  index == 0 ? rateOneValueController : rateTwoValueController,
              keyboardType: TextInputType.number,
              decoration: customTfInputDecoration("Rate *")),
        ),
        IconButton(
          icon: Icon(isFirstRow ? Icons.add : Icons.remove),
          onPressed: () {
            try {
              if (isMaxRowsReached) {
                // Show a warning dialog when max rows are reached
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Warning'),
                      content:
                          const Text('You cannot add more than 2 tax rows.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                setState(() {
                  if (isFirstRow) {
                    var newKey = GlobalKey();
                    taxRateRowKeys.insert(index + 1, newKey);
                    taxRateRows.insert(
                        index + 1, _buildTaxRateRow(newKey, index + 1));
                    rateControllers[index + 1] = '';
                    taxControllers[index + 1] = '';
                  } else {
                    taxRateRowKeys.removeAt(index);
                    taxRateRows.removeAt(index);
                    rateControllers.remove(index);
                    taxControllers.remove(index);
                  }
                });
              }
            } catch (e) {
              Result.error("Book list not available");
            }
          },
        ),
      ],
    );
  }
}

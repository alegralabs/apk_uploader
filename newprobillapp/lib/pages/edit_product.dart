import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:newprobillapp/components/api_constants.dart';

import 'package:newprobillapp/components/color_constants.dart';
import 'package:newprobillapp/components/custom_components.dart';
import 'package:newprobillapp/pages/login_page.dart';
import 'package:newprobillapp/services/api_services.dart';
import 'package:newprobillapp/services/result.dart';

class ProductEditPage extends StatefulWidget {
  final int productId;

  const ProductEditPage({super.key, required this.productId});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  late TextEditingController itemNameController;
  late TextEditingController quantityController;
  late TextEditingController salePriceController;
  late TextEditingController mrpController;
  TextEditingController rateOneValueController = TextEditingController();
  TextEditingController rateTwoValueController = TextEditingController();
  late TextEditingController tax1Controller;
  late TextEditingController tax2Controller;
  late String fullUnitDropdownValue;
  late String shortUnitDropdownValue;
  late String tax1DropdownValue;
  late String tax2DropdownValue;
  late String hsn;

  List<String> fullUnits = [
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
  Map<int, String> rateControllers = {};
  Map<int, String> taxControllers = {};

  String? token;
  String? apiKey;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    itemNameController = TextEditingController();
    quantityController = TextEditingController();
    salePriceController = TextEditingController();
    tax1Controller = TextEditingController();
    tax2Controller = TextEditingController();
    rateTwoValueController = TextEditingController();
    rateOneValueController = TextEditingController();
    mrpController = TextEditingController();
    fullUnitDropdownValue = 'Full Unit';
    shortUnitDropdownValue = 'Short Unit';
    tax1DropdownValue = 'GST';
    tax2DropdownValue = 'CESS';
    fullUnits = fullUnits.toSet().toList();
    shortUnits = shortUnits.toSet().toList();
    var key = GlobalKey();
    taxRateRowKeys.add(key);
    taxRateRows.add(_buildTaxRateRow(key, 0));
    // Fetch product details when the page is initialized
    _initializeData();
  }

  @override
  void dispose() {
    mrpController.dispose();
    itemNameController.dispose();
    quantityController.dispose();
    salePriceController.dispose();
    tax1Controller.dispose();
    tax2Controller.dispose();
    rateOneValueController.dispose();
    rateTwoValueController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    token = await APIService.getToken();
    apiKey = await APIService.getXApiKey();
    APIService.getUserDetails(token, _showFailedDialog);
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    print("Hello World");
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http
          .get(Uri.parse('$baseUrl/item/${widget.productId}'), headers: {
        'Authorization': 'Bearer $token',
        'auth-key': '$apiKey',
      });
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body)['data'];
        print(jsonData);
        setState(() {
          itemNameController.text = jsonData['item_name'];
          quantityController.text = jsonData['quantity'];
          salePriceController.text = jsonData['sale_price'];
          tax1DropdownValue = jsonData['tax1'];
          tax2DropdownValue = jsonData['tax2'];
          rateOneValueController.text = jsonData['rate1'];
          rateTwoValueController.text = jsonData['rate2'];
          mrpController.text = jsonData['mrp'];
          fullUnitDropdownValue = jsonData['full_unit'];
          shortUnitDropdownValue = jsonData['short_unit'];
          hsn = jsonData['hsn'];
        });
      } else {
        Result.error("Book list not available");
      }
    } catch (error) {
      Result.error("Book list not available");
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

  Widget _buildCombinedDropdown(
      String label, List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: customTfInputDecoration(label),
      value: items[0], // Initial value
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _updateProduct() async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/update-item'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': widget.productId,
          'mrp': mrpController.text,
          'item_name': itemNameController.text,
          'quantity': quantityController.text,
          'sale_price': salePriceController.text,
          'full_unit': fullUnitDropdownValue,
          'short_unit': shortUnitDropdownValue,
          'rate1': rateOneValueController.text,
          'rate2': rateTwoValueController.text,
          'tax1': tax1DropdownValue,
          'tax2': tax2DropdownValue,
          'hsn': hsn,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        Fluttertoast.showToast(msg: jsonResponse['message']);
        Navigator.of(context).pop();
      } else {
        var jsonResponse = jsonDecode(response.body);
        Fluttertoast.showToast(msg: jsonResponse['data'].toString());
        print(response.body);
        Result.error("Book list not available");
      }
    } catch (error) {
      Result.error("Book list not available");
      print(error);
    }
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
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar('Edit Product'),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  green2,
                ), // Change color here
              ), // Show loading indicator
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    _buildTextField(itemNameController, 'Item Name'),
                    const SizedBox(
                      height: 15,
                    ),
                    _buildTextField(quantityController, 'Stock Quantity'),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCombinedDropdown('Unit', [
                            'Full Unit (Short Unit)',
                            ...fullUnits
                                .map((unit) =>
                                    '$unit (${shortUnits[fullUnits.indexOf(unit)]})')
                                .toList()
                          ], (value) {
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
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(mrpController, 'MRP')),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                              salePriceController, 'Sale Price'),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
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
                    customElevatedButton(
                      "Save Changes",
                      green2,
                      white,
                      () {
                        _updateProduct();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: customTfInputDecoration(hintText),
    );
  }

  Widget _buildDropdown(String hintText, List<String> dropdownItems,
      String unitDropdownValue, void Function(String) updateDropdownValue) {
    return DropdownButtonFormField<String>(
      // Set the value of the dropdown
      items: dropdownItems.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        // Call the callback function to update the dropdown value
        updateDropdownValue(value!);
      },
      decoration: customTfInputDecoration(hintText),
    );
  }
}

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:newprobillapp/components/api_constants.dart';
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
  late TextEditingController rate2Controller;
  late TextEditingController rate1Controller;
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

  String? token;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    itemNameController = TextEditingController();
    quantityController = TextEditingController();
    salePriceController = TextEditingController();
    tax1Controller = TextEditingController();
    tax2Controller = TextEditingController();
    rate2Controller = TextEditingController();
    rate1Controller = TextEditingController();
    mrpController = TextEditingController();
    fullUnitDropdownValue = 'Full Unit';
    shortUnitDropdownValue = 'Short Unit';
    tax1DropdownValue = 'GST';
    tax2DropdownValue = 'CESS';
    fullUnits = fullUnits.toSet().toList();
    shortUnits = shortUnits.toSet().toList();
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
    rate1Controller.dispose();
    rate2Controller.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    token = await APIService.getToken();
    APIService.getUserDetails(token, _showFailedDialog);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProductDetails());
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http
          .get(Uri.parse('$baseUrl/item/${widget.productId}'), headers: {
        'Authorization': 'Bearer $token',
      });
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body)['data'];
        setState(() {
          itemNameController.text = jsonData['item_name'];
          quantityController.text = jsonData['quantity'];
          salePriceController.text = jsonData['sale_price'];
          tax1DropdownValue = jsonData['tax1'];
          tax2DropdownValue = jsonData['tax2'];
          rate1Controller.text = jsonData['rate1'];
          rate2Controller.text = jsonData['rate2'];
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
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
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
          'rate1': rate1Controller.text,
          'rate2': rate2Controller.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 247, 255, 1),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Item Detail',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: const Color.fromRGBO(
            243, 203, 71, 1), // Change this color to whatever you desire
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(243, 203, 71, 1),
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
                    Row(children: [
                      Expanded(
                        child: _buildDropdown(
                          'GST',
                          ['GST', 'CESS'],
                          tax1DropdownValue, // Add your tax options here
                          (value) {
                            setState(() {
                              tax1DropdownValue = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(child: _buildTextField(rate1Controller, "Rate")),
                    ]),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(children: [
                      Expanded(
                        child: _buildDropdown(
                          'CESS',
                          ['GST', 'CESS'],
                          tax2DropdownValue, // Add your tax options here
                          (value) {
                            setState(() {
                              tax2DropdownValue = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(child: _buildTextField(rate2Controller, "Rate")),
                    ]),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        print({
                          'id': widget.productId,
                          'mrp': mrpController.text,
                          'item_name': itemNameController.text,
                          'quantity': quantityController.text,
                          'sale_price': salePriceController.text,
                          'full_unit': fullUnitDropdownValue,
                          'short_unit': shortUnitDropdownValue,
                          'rate1': rate1Controller.text,
                          'rate2': rate2Controller.text,
                          'tax1': tax1DropdownValue,
                          'tax2': tax2DropdownValue,
                        });
                        _updateProduct();
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xff28a745),
                        ), // Change color here
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
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
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
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
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

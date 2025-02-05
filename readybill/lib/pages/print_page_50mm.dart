import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:provider/provider.dart';
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:readybill/services/global_internet_connection_handler.dart';
import 'package:readybill/services/home_bill_item_provider.dart';

class PrintPage50mm extends StatefulWidget {
  final Function clearData;
  final List data;
  final String totalAmount;
  const PrintPage50mm(
      {super.key,
      required this.data,
      required this.totalAmount,
      required this.clearData});

  @override
  State<PrintPage50mm> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage50mm> {
  ReceiptController? controller;
  String shopName = '';
  String address = '';
  String phone = '';
  String imageUrl = '';
  String gstIn = '';
  Image logo = Image.asset('assets/ReadyBillBlack.png');

  Future<void> printIt() async {
    final device = await FlutterBluetoothPrinter.selectDevice(context);
    if (device != null) {
      controller?.print(address: device.address);
    }
  }

  Future<void> _getData() async {
    String? token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();

    final response = await http.get(
      Uri.parse('$baseUrl/user-detail'),
      headers: {'Authorization': 'Bearer $token', 'auth-key': '$apiKey'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (mounted) {
        setState(() {
          imageUrl = jsonData['logo'];
          imageUrl == "assets/img/user.jpg"
              ? logo = Image.asset('assets/ReadyBillBlack.png')
              : logo = Image.network(imageUrl);

          shopName = jsonData['data']['details']['business_name'];
          address = jsonData['data']['details']['address'];
          phone = jsonData['data']['mobile'];
          gstIn = jsonData['data']['shop']['gstin'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
    Future.delayed(const Duration(milliseconds: 1000), () {
      printIt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Print Page"),
      body: Column(
        children: [
          Expanded(
            child: Receipt(
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: 100, maxWidth: 100),
                      child: Image(
                        image: logo.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(shopName, style: const TextStyle(fontSize: 17))
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(address, style: const TextStyle(fontSize: 17))
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(phone, style: const TextStyle(fontSize: 17))
                    ],
                  ),
                  const SizedBox(height: 5),
                  gstIn != 'N/A'
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(gstIn, style: const TextStyle(fontSize: 17))
                          ],
                        )
                      : const SizedBox.shrink(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowHeight: 22,
                        dividerThickness: 0,
                        horizontalMargin: 0,
                        headingRowColor: WidgetStatePropertyAll(black),
                        columns: const [
                          DataColumn(
                              label: Text(
                            "ITEM",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: white),
                          )),
                          DataColumn(
                              label: Text(
                            "QUANTITY",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: white),
                          )),
                          DataColumn(
                              label: Text(
                            "PRICE",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: white),
                          )),
                        ],
                        rows: widget.data.map<DataRow>((item) {
                          return DataRow(cells: [
                            DataCell(
                              Text(
                                item['itemName'],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            DataCell(Text(
                              item['quantity'].toString(),
                              style: const TextStyle(fontSize: 18),
                            )),
                            DataCell(Text(
                              item['amount'].toString(),
                              style: const TextStyle(fontSize: 18),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Total: ${widget.totalAmount}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              onInitialized: (controller) {
                this.controller = controller;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: customElevatedButton(
              "Print",
              blue,
              white,
              printIt,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:intl/intl.dart';

import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrintPage extends StatefulWidget {
  final Function? clearData;
  final List data;
  final String totalAmount;
  final String invoiceNumber;
  const PrintPage(
      {super.key,
      required this.data,
      required this.totalAmount,
      this.clearData,
      required this.invoiceNumber});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  ReceiptController? controller;
  String shopName = '';
  String address = '';
  String phone = '';
  String imageUrl = '';
  String gstIn = '';
  Image logo = Image.asset('assets/ReadyBillBlack.png');

  Future<void> printIt() async {
    controller!.paperSize = PaperSize.mm58;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final deviceAddress = prefs.getString('printerAddress');
    if (deviceAddress != null) {
      controller?.print(address: deviceAddress);
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
      appBar: customAppBar("Print Page",[]),
      body: Column(
        children: [
          Expanded(
            child: Receipt(
              //   paperSize: PaperSize.mm58,
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
                            Text("GST no: $gstIn",
                                style: const TextStyle(fontSize: 17))
                          ],
                        )
                      : const SizedBox.shrink(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "INVOICE",
                        style: TextStyle(
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 1,
                    color: black,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Invoice No: ${widget.invoiceNumber}",
                          style: const TextStyle(fontSize: 17))
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text("Date: ", style: TextStyle(fontSize: 17)),
                    Text(
                        DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now()),
                        style: const TextStyle(fontSize: 17))
                  ]),
                  const Divider(
                    thickness: 1,
                    color: black,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowHeight: 22,
                        dividerThickness: 0,
                        horizontalMargin: 0,
                        columnSpacing:
                            20, // Add this to control space between columns
                        columns: const [
                          DataColumn(
                            label: Text(
                              "ITEM",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Add this to control column width
                            tooltip: "Item Name",
                          ),
                          DataColumn(
                            label: Text(
                              "QUANTITY",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "PRICE",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: widget.data.map<DataRow>((item) {
                          return DataRow(cells: [
                            DataCell(
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(
                                  item['itemName'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            DataCell(Text(
                              item['quantity'].toString(),
                              style: const TextStyle(fontSize: 18),
                            )),
                            DataCell(
                              Text(
                                item['amount'].toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
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
                  const Divider(
                    thickness: 1,
                    color: black,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "THANK YOU",
                        style: TextStyle(
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
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

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';

class PrintPage extends StatefulWidget {
  final List data;
  final String totalAmount;
  const PrintPage({super.key, required this.data, required this.totalAmount});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  ReceiptController? controller;

  Future<void> printIt() async {
    final device = await FlutterBluetoothPrinter.selectDevice(context);
    if (device != null) {
      controller?.print(address: device.address);
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.data.toString());
    print(widget.totalAmount.toString());
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
                  Image.asset(
                    "assets/ReadyBillBlack.png",
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: DataTable(
                        horizontalMargin: 0,
                        columns: const [
                          DataColumn(label: Text("Item")),
                          DataColumn(label: Text("Quantity")),
                          DataColumn(label: Text("Price")),
                        ],
                        rows: widget.data.map<DataRow>((item) {
                          return DataRow(cells: [
                            DataCell(
                              Text(
                                item['itemName'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            DataCell(Text(
                              item['quantity'].toString(),
                              style: const TextStyle(fontSize: 20),
                            )),
                            DataCell(Text(
                              item['amount'].toString(),
                              style: const TextStyle(fontSize: 20),
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

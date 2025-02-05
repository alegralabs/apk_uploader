import 'package:flutter/material.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';

class HowToUploadXlsPage extends StatelessWidget {
  const HowToUploadXlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("How To Upload"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "XLS:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              'You can add your inventory items one-by-one using the “Add Inventory menu”. This is convenient when there are only few items that you can manually add them one-by-one, but this is not the best idea when you have to upload hundreds of items at once.',
            ),
            const Text(
              "The “Upload Data” button in the “Add Inventory” page allows you to upload inventory data in CSV or XLS format. All you have to do is keep your data in the following format –",
            ),
            const SizedBox(
              height: 10,
            ),
            Table(
              border: TableBorder.all(color: black),
              children: const [
                TableRow(children: [
                  Text(
                    "Item Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Minimum Stock Alert',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "MRP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sale Price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Unit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "HSN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'GST',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'CESS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ])
              ],
            )
          ],
        ),
      ),
    );
  }
}

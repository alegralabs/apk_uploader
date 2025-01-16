import 'package:flutter/material.dart';
import 'package:readybill/components/bottom_navigation_bar.dart';
import 'package:readybill/components/custom_components.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final List<Item> _items = List<Item>.generate(6, (index) {
    return Item(
        title: "Support Title $index", subTitle: "Support SubTitle $index");
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Support"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _items[index].isExpanded = isExpanded;
                    });
                  },
                  children: _items.map<ExpansionPanel>((Item item) {
                    return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(title: Text(item.title));
                        },
                        body: ListTile(title: Text(item.subTitle)),
                        isExpanded: item.isExpanded);
                  }).toList(),
                ),
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

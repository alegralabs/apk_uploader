import 'package:flutter/material.dart';
import 'package:readybill/components/bottom_navigation_bar.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  TextEditingController questionTitleController = TextEditingController();
  TextEditingController questionBodyController = TextEditingController();
  final List<Item> _items = List<Item>.generate(6, (index) {
    return Item(
        title: "Support Title $index", subTitle: "Support SubTitle $index");
  });

  questionModalBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
              child: Text("ENTER YOUR QUESTION",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          const Text(
            "Title: ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: questionTitleController,
            decoration: customTfInputDecoration("Title"),
          ),
          const SizedBox(height: 16),
          const Text(
            "Details: ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: questionBodyController,
            decoration: customTfInputDecoration("Details"),
          ),
          const SizedBox(height: 16),
          customElevatedButton("Add Attachment", blue, white, () {}),
          const SizedBox(height: 16),
          SizedBox(
              width: double.maxFinite,
              child: customElevatedButton("Submit", green2, white, () {})),
        ],
      ),
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
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => questionModalBottomSheet());
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

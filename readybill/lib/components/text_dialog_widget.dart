import 'package:flutter/material.dart';

Future showTextDialog(context, {title, value}) => showDialog(
    context: context,
    builder: (context) => TextDialogWidget(
          title: title,
          value: value,
        ));

class TextDialogWidget extends StatefulWidget {
  final String title;
  final String value;
  const TextDialogWidget({super.key, required this.title, required this.value});

  @override
  State<TextDialogWidget> createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
            child: const Text('Done'))
      ],
    );
  }
}

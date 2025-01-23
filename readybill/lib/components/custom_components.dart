import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readybill/components/color_constants.dart';

InputDecoration customTfInputDecoration(String hintText) {
  return InputDecoration(
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
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );
}

InputDecoration phoneNumberInputDecoration(String hintText) {
  return InputDecoration(
    prefixIcon: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "  +91  ",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          //  textAlign: TextAlign.,
        ),
      ],
    ),
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
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );
}

ElevatedButton customElevatedButton(String text, Color backgroundColor,
    Color textColor, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(textColor),
        backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        )),
    child: Text(text),
  );
}

InputDecoration customTfDecorationWithSuffix(
    String hintText, Widget? suffix, FocusNode focusNode) {
  return InputDecoration(
    hintText: hintText,
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
    suffixIcon: suffix != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0)),
              color: focusNode.hasFocus ? green2 : darkGrey,
            ),
            child: suffix,
          )
        : null,
  );
}

customAppBar(String title) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
          fontFamily: 'Roboto_Regular', fontWeight: FontWeight.w500),
    ),
    backgroundColor: green2,
  );
}

customToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: green2,
      textColor: black,
      fontSize: 16.0);
}

customAlertBox(
    {required String title,
    required String content,
    required List<Widget> actions}) {
  return AlertDialog(
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto_Regular',
      ),
      textAlign: TextAlign.center,
    ),
    content: Text(
      content,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto_Regular',
      ),
      textAlign: TextAlign.center,
    ),
    actions: actions,
    actionsAlignment: MainAxisAlignment.spaceEvenly,
  );
}

labeltext(String label) {
  return Text(
    label,
    style: const TextStyle(
        color: black,
        fontFamily: 'Roboto_Regular',
        fontWeight: FontWeight.bold,
        fontSize: 16),
  );
}

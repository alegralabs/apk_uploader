import 'package:flutter/material.dart';
import 'package:readybill/components/color_constants.dart';

class SubscriptionExpiryAlert extends StatelessWidget {
  final int isSubscriptionExpired;
  final String daysLeft;

  const SubscriptionExpiryAlert({
    super.key,
    required this.daysLeft,
    required this.isSubscriptionExpired,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: red.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: const Text(
        "Subscription Alert",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: Text(
        isSubscriptionExpired == 0
            ? "Your subscription has expired. Please renew your subscription to continue using ReadyBill."
            : "Your subscription will expire in $daysLeft days. Please renew your subscription to continue using ReadyBill.",
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

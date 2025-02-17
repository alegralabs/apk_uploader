import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/pages/subscriptions.dart';
import 'package:readybill/services/global_internet_connection_handler.dart';

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
        customElevatedButton("OK", green2, white, () {
          navigatorKey.currentState!.pop();
          navigatorKey.currentState!.push(
              CupertinoPageRoute(builder: (context) => const Subscriptions()));
        }),
        customElevatedButton("Cancel", red, white, () {
          navigatorKey.currentState!.pop();
        })
      ],
    );
  }
}

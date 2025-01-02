// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newprobillapp/components/api_constants.dart';
import 'package:newprobillapp/components/color_constants.dart';
import 'package:newprobillapp/services/api_services.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  List<dynamic> plans = [];

  getPlans() async {
    var token = await APIService.getToken();

    var apiKey = await APIService.getXApiKey();
    Uri url = Uri.parse("$baseUrl/subscription-plans");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'auth-key': '$apiKey',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      plans = jsonData['data'];
      print(plans);
    }
  }

  initState() {
    super.initState();
    getPlans();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: const Text("Subscriptions"),
      backgroundColor: green2,
    );
    final screenHeight =
        MediaQuery.of(context).size.height - appBar.preferredSize.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: white,
      appBar: appBar,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                screenWidth * 0.07, screenWidth * 0.07, screenWidth * 0.07, 0),
            height: screenHeight * 0.23,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.grey.withOpacity(0.2),
            ),
            child: Column(children: [
              Text(
                plans[0]['plan_name'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto_Regular',
                    fontSize: 20),
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Price: ₹${plans[0]['price'].toString()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto_Regular',
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(green),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Upgrade Now',
                  style: TextStyle(color: white),
                ),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                screenWidth * 0.07, screenWidth * 0.07, screenWidth * 0.07, 0),
            height: screenHeight * 0.23,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.grey.withOpacity(0.2),
            ),
            child: Column(children: [
              Text(
                plans[1]['plan_name'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto_Regular',
                    fontSize: 20),
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Price: ₹${plans[1]['price'].toString()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto_Regular',
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(green),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Upgrade Now',
                  style: TextStyle(color: white),
                ),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                screenWidth * 0.07, screenWidth * 0.07, screenWidth * 0.07, 0),
            height: screenHeight * 0.23,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.grey.withOpacity(0.2),
            ),
            child: Column(children: [
              Text(
                plans[2]['plan_name'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto_Regular',
                    fontSize: 20),
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Price: ₹${plans[2]['price'].toString()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto_Regular',
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(green),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Upgrade Now',
                  style: TextStyle(color: white),
                ),
              ),
            ]),
          ),
          SizedBox(
            height: screenHeight * 0.1,
          )
        ],
      ),
    );
  }
}

// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:newprobillapp/components/api_constants.dart';
import 'package:newprobillapp/components/color_constants.dart';
import 'package:newprobillapp/components/custom_components.dart';
import 'package:newprobillapp/services/api_services.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  List<dynamic> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPlans();
  }

  Future<void> getPlans() async {
    try {
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
        setState(() {
          plans = jsonData['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching plans: $e');
    }
  }

  Widget buildPlanCard(
      Map<String, dynamic> plan, double screenHeight, double screenWidth) {
    return Container(
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
          plan['plan_name'],
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto_Regular',
              fontSize: 20),
        ),
        const Divider(thickness: 2),
        const SizedBox(height: 10),
        Text(
          "Price: ₹${plan['price'].toString()}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto_Regular',
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 10),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = customAppBar("Subscriptions");

    final screenHeight =
        MediaQuery.of(context).size.height - appBar.preferredSize.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: white,
      appBar: appBar,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? const Center(child: Text('No subscription plans available'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ...plans.map((plan) =>
                          buildPlanCard(plan, screenHeight, screenWidth)),
                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                ),
    );
  }
}

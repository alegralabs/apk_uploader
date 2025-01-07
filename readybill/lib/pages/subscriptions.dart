// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/services/api_services.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  List<dynamic> plans = [];
  bool isLoading = true;
  String currentPlan = '';
  String expiryDate = '';

  @override
  void initState() {
    super.initState();
    getPlans();
    getCurrentPlan();
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

  getCurrentPlan() async {
    var token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();
    try {
      Uri url = Uri.parse("$baseUrl/user-detail");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'auth-key': '$apiKey',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          currentPlan = jsonData["subscription_current_plan"];
          expiryDate = jsonData["subscription_expiry_date"];
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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: lightGrey,
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: screenWidth * 0.85,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Current Plan Details",
                                style: TextStyle(
                                    fontFamily: 'Roboto_Regular',
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Plan: $currentPlan",
                                style: const TextStyle(
                                  fontFamily: 'Roboto_Regular',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Expiry Date: $expiryDate",
                                style: const TextStyle(
                                  fontFamily: 'Roboto_Regular',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                      ),
                      ...plans.map((plan) =>
                          buildPlanCard(plan, screenHeight, screenWidth)),
                      const SizedBox(height: 20),
                      const Text(
                        "Sales and Technical Support",
                        style: TextStyle(
                            fontFamily: 'Roboto_Regular',
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: green),
                          Text(
                            "+91 88227 74191 / +91 98640 81806",
                            style: TextStyle(
                              fontFamily: 'Roboto_Regular',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email, color: green),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "info@alegralabs.com",
                            style: TextStyle(
                              fontFamily: 'Roboto_Regular',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                ),
    );
  }
}

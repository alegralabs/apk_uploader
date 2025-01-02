import 'package:flutter/material.dart';
import 'package:newprobillapp/pages/splash_screen.dart';
import 'package:newprobillapp/services/global_internet_connection_handler.dart';
import 'package:newprobillapp/services/home_bill_item_provider.dart';
// import 'package:newprobillapp/services/local_database.dart';
import 'package:newprobillapp/services/refund_bill_item_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeBillItemProvider()),
        ChangeNotifierProvider(create: (_) => RefundBillItemProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const InternetConnectivityHandler(
      child: SplashScreen(),
    );
  }
}

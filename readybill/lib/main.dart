import 'package:flutter/material.dart';
import 'package:readybill/pages/splash_screen.dart';
import 'package:readybill/services/global_internet_connection_handler.dart';
import 'package:readybill/services/home_bill_item_provider.dart';
// import 'package:readybill/services/local_database.dart';
import 'package:readybill/services/refund_bill_item_provider.dart';
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

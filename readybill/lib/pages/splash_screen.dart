import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/pages/home_page.dart';
import 'package:readybill/pages/login_page.dart';
import 'package:readybill/services/api_services.dart';
import 'package:readybill/services/global_internet_connection_handler.dart';
import 'package:readybill/services/local_database_2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  //bool _isLoggedIn = false;
  late AnimationController _controller;
  late Animation<double> _logoWidthAnimation;
  late Animation<double> _logoOpacityAnimation;
  @override
  void initState() {
    super.initState();
    _checkInternet();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoWidthAnimation = Tween<double>(
      begin: 0.0,
      end: 300.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6), // First 60% of the animation
      ),
    );

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 1.0), // Last 40% of the animation
      ),
    );

    _controller.forward();
  }

  Future<void> _checkInternet() async {
    print('checking internet');
    bool result = await InternetConnection().hasInternetAccess;
    if (result) {
      _checkPermissionsAndLogin();
      //LocalDatabase.instance.clearTable();
      //LocalDatabase.instance.fetchDataAndStoreLocally();
    } else {
      _noInternetDialog();
    }
  }

  void _noInternetDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => customAlertBox(
              title: 'No Internet Connection',
              content: 'Please check your internet connection and try again.',
              actions: <Widget>[
                customElevatedButton('Retry', green2, white, () {
                  navigatorKey.currentState?.pop();
                  _checkInternet();
                }),
                TextButton(
                    onPressed: () {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      }
                      if (Platform.isIOS) {
                        exit(0);
                      }
                    },
                    child: const Text('Exit')),
              ],
            ));
  }

  Future<void> _checkPermissionsAndLogin() async {
    print('checking permissions');
    await _checkAndRequestPermissionStorage();
    await handleLogin();
  }

  Future<void> _checkAndRequestPermissionStorage() async {
    print('checking storage permission');
    var status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      print('permission not granted');
      await Permission.storage.request();
    }
  }

  Future<void> handleLogin() async {
    print('handling login');
    String? token = await APIService.getToken();
    // print(token);
    if (token != null) {
      int statusReturnCode =
          await APIService.getUserDetailsWithoutDialog(token);
      print("statusReturnCode: $statusReturnCode");
      if (statusReturnCode == 404 || statusReturnCode == 333) {
        print("statusReturnCode: $statusReturnCode");
        // print('token: $token');

        _navigateToLoginScreen();
      } else if (statusReturnCode == 200) {
        print('statusCode: $statusReturnCode');
        LocalDatabase2.instance.clearTable();
        LocalDatabase2.instance.fetchDataAndStoreLocally();
        _navigateToSearchApp();
        await _setLoggedInStatus(true); // Ensure this is awaited
      } else {
        _navigateToLoginScreen();
      }
    } else {
      _navigateToLoginScreen();
    }
    setState(() {
      //_isLoggedIn = true;
    });
  }

  Future<void> _setLoggedInStatus(bool isLoggedIn) async {
    print('setting logged in status: $isLoggedIn');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn); // Ensure this is awaited
  }

  Future<bool> _getLoggedInStatus() async {
    print('getting logged in status');
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  void _navigateToLoginScreen() {
    print("navigate to login screen");
    Future.delayed(const Duration(milliseconds: 2200), () {
      navigatorKey.currentState?.pushReplacement(
        CupertinoPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  void _navigateToSearchApp() {
    print("navigate to search app");
    Future.delayed(const Duration(milliseconds: 2200), () {
      navigatorKey.currentState?.pushReplacement(
        CupertinoPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoWidthAnimation,
              builder: (context, child) {
                return Container(
                  width: _logoWidthAnimation.value,
                  child: child,
                );
              },
              child: Image.asset("assets/ReadyBillBlack.png"),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _logoOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacityAnimation.value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/AlegraLabsBlack.png',
                width: 240,
              ),
            ),
            const SizedBox(height: 180),
          ],
        ),
      ),
    );
  }
}

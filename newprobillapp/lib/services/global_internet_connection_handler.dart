import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:newprobillapp/components/color_constants.dart';

// Global key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class InternetConnectivityHandler extends StatefulWidget {
  final Widget child;

  const InternetConnectivityHandler({
    super.key,
    required this.child,
  });

  @override
  State<InternetConnectivityHandler> createState() =>
      _InternetConnectivityHandlerState();
}

class _InternetConnectivityHandlerState
    extends State<InternetConnectivityHandler> with WidgetsBindingObserver {
  late InternetConnection _internetConnection;
  StreamSubscription? _connectivitySubscription;
  bool _isNoInternetScreenShowing = false;
  Timer? _noInternetTimer;

  @override
  void initState() {
    super.initState();
    _internetConnection = InternetConnection();
    WidgetsBinding.instance.addObserver(this);
    _initializeConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _noInternetTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeConnectivityListener() async {
    try {
      // Initial check
      bool hasInternet = await _internetConnection.hasInternetAccess;
      if (mounted) {
        _handleConnectivityChange(hasInternet);
      }

      // Start listening to changes
      _connectivitySubscription?.cancel(); // Cancel any existing subscription
      _connectivitySubscription = _internetConnection.onStatusChange.listen(
        (InternetStatus status) {
          if (mounted) {
            _handleConnectivityChange(status == InternetStatus.connected);
          }
        },
        onError: (error) {
          debugPrint('Connectivity error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error initializing connectivity listener: $e');
    }
  }

  void _handleConnectivityChange(bool hasInternet) {
    debugPrint('Connectivity changed: hasInternet = $hasInternet');
    var lastRoute = ModalRoute.of(context);
    print("lastRoute: $lastRoute");

    // Cancel any existing timer
    _noInternetTimer?.cancel();

    if (!hasInternet && !_isNoInternetScreenShowing) {
      // Start a new timer when internet is lost
      _noInternetTimer = Timer(const Duration(seconds: 3), () {
        if (!hasInternet && mounted && !_isNoInternetScreenShowing) {
          _isNoInternetScreenShowing = true;
          navigatorKey.currentState?.push(
            CupertinoPageRoute(builder: (_) => const NoInternetScreen()),
          );
        }
      });
    } else if (hasInternet && _isNoInternetScreenShowing) {

      _noInternetTimer?.cancel();
      _isNoInternetScreenShowing = false;
      navigatorKey.currentState?.pop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeConnectivityListener();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: green2,
          brightness: Brightness.light,
          primary: green2,
        ),
      ),
      navigatorKey: navigatorKey,
      home: widget.child,
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
    );
  }
}

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 80,
                    color: red,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Internet Connection',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: red,
                        ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(red),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

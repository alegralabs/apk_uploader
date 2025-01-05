import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:newprobillapp/components/color_constants.dart';

class InternetChecker extends StatefulWidget {
  final Widget child;
  final Widget? noInternetWidget;
  final Duration debounceDuration;

  const InternetChecker({
    super.key,
    required this.child,
    this.noInternetWidget,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<InternetChecker> createState() => _InternetCheckerState();
}

class _InternetCheckerState extends State<InternetChecker>
    with WidgetsBindingObserver {
  bool _isConnectedToInternet = true;
  Timer? _debounceTimer;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeConnectivityListener();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeConnectivityListener() async {
    // Check initial connection status
    _isConnectedToInternet = await InternetConnection().hasInternetAccess;
    if (mounted) setState(() {});

    // Listen for subsequent changes
    _connectivitySubscription =
        InternetConnection().onStatusChange.listen((status) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration, () {
        if (mounted) {
          setState(() {
            _isConnectedToInternet = status == InternetStatus.connected;
          });
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeConnectivityListener();
    }
  }

  Widget _buildNoInternetWidget() {
    return widget.noInternetWidget ??
        Material(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  color: red,
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: red),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'No Internet Connection',
                              style: TextStyle(
                                color: red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Please check your internet connection and try again',
                              style: TextStyle(
                                color: red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _isConnectedToInternet ? widget.child : _buildNoInternetWidget();
  }
}

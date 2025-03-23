import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsugar/services/connectivity_service.dart';
import 'package:fitsugar/screens/no_wifi_screen.dart';

/// A widget that monitors connectivity and shows a No WiFi screen when offline.
/// All app screens can be wrapped with this to handle connection status.
class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final bool showNoWifiOnDisconnect;

  const ConnectivityWrapper({
    Key? key,
    required this.child,
    this.showNoWifiOnDisconnect = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        if (!connectivity.isConnected && showNoWifiOnDisconnect) {
          return const NoWifiScreen();
        }
        return child;
      },
    );
  }
}

/// Extension method to easily wrap any widget with ConnectivityWrapper
extension ConnectivityWrapperExtension on Widget {
  Widget withConnectivityHandler({bool showNoWifiOnDisconnect = true}) {
    return ConnectivityWrapper(
      showNoWifiOnDisconnect: showNoWifiOnDisconnect,
      child: this,
    );
  }
}
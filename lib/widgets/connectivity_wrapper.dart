import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsugar/services/connectivity_service.dart';
import 'package:fitsugar/screens/no_wifi_screen.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final bool showNoWifiOnDisconnect;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.showNoWifiOnDisconnect = true,
  });

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

///extension method to wrap any widget
extension ConnectivityWrapperExtension on Widget {
  Widget withConnectivityHandler({bool showNoWifiOnDisconnect = true}) {
    return ConnectivityWrapper(
      showNoWifiOnDisconnect: showNoWifiOnDisconnect,
      child: this,
    );
  }
}
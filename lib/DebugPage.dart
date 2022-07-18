import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'Keys.dart';
import 'MatchJoiner.dart';
import 'main.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DebugPageState();
}

class DebugPageState extends State<DebugPage> {
  String wifiName;
  String wifiBSSID;
  String wifiIP;
  String wifiIPv6;
  String wifiSubmask;
  String wifiBroadcast;
  String wifiGateway;

  String _connectionStatus = 'Unknown';
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  void initState() {
    super.initState();
    fetchIPInfo();
    _initNetworkInfo();
    _enablePlatformOverrideForDesktop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (() {
        var strings = <String>[];
        strings.add(_connectionStatus);
        // strings.add(wifiName);
        // strings.add(wifiBSSID);
        // strings.add(wifiIP);
        // strings.add(wifiIPv6);
        // strings.add(wifiSubmask);
        // strings.add(wifiBroadcast);
        // strings.add(wifiGateway);

        return ListView(
            padding: const EdgeInsets.all(12),
            children: strings
                .map<Container>((s) => Container(
                      child: Center(
                          child: Text(
                        s ?? "---",
                        textScaleFactor: 1.3,
                        textAlign: TextAlign.center,
                      )),
                      margin: EdgeInsets.all(20),
                    ))
                .toList());
      }()),
      floatingActionButton: Consumer<Settings>(
        builder: (context, settings, child) => FloatingActionButton(
          onPressed: () {
            fetchIPInfo();
            _initNetworkInfo();
            _enablePlatformOverrideForDesktop();
          },
          child: const Icon(Icons.refresh),
          tooltip: "Retry",
          backgroundColor: Colors.red,
        ),
      ),
    );
  }

  void fetchIPInfo() {
    final info = NetworkInfo();

    // setState(() {
    //   wifiName = await info.getWifiName(); // FooNetwork
    //   wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66
    //   wifiIP = await info.getWifiIP(); // 192.168.1.43
    //   wifiIPv6 =
    //       await info.getWifiIPv6(); // 2001:0db8:85a3:0000:0000:8a2e:0370:7334
    //   wifiSubmask = await info.getWifiSubmask(); // 255.255.255.0
    //   wifiBroadcast = await info.getWifiBroadcast(); // 192.168.1.255
    //   wifiGateway = await info.getWifiGatewayIP(); // 192.168.1.1
    // });
  }


  Future<void> _initNetworkInfo() async {
    String wifiName,
        wifiBSSID,
        wifiIPv4,
        wifiIPv6,
        wifiGatewayIP,
        wifiBroadcast,
        wifiSubmask;

    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiName = await _networkInfo.getWifiName();
        } else {
          wifiName = await _networkInfo.getWifiName();
        }
      } else {
        wifiName = await _networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      wifiName = 'Failed to get Wifi Name';
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        } else {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        }
      } else {
        wifiBSSID = await _networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi BSSID', error: e);
      wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    try {
      wifiIPv6 = await _networkInfo.getWifiIPv6();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
      wifiIPv6 = 'Failed to get Wifi IPv6';
    }

    try {
      wifiSubmask = await _networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      wifiSubmask = 'Failed to get Wifi submask address';
    }

    try {
      wifiBroadcast = await _networkInfo.getWifiBroadcast();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi broadcast', error: e);
      wifiBroadcast = 'Failed to get Wifi broadcast';
    }

    try {
      wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }

    try {
      wifiSubmask = await _networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask', error: e);
      wifiSubmask = 'Failed to get Wifi submask';
    }

    setState(() {
      _connectionStatus = 'Wifi Name: $wifiName\n'
          'Wifi BSSID: $wifiBSSID\n'
          'Wifi IPv4: $wifiIPv4\n'
          'Wifi IPv6: $wifiIPv6\n'
          'Wifi Broadcast: $wifiBroadcast\n'
          'Wifi Gateway: $wifiGatewayIP\n'
          'Wifi Submask: $wifiSubmask\n';
    });
  }

  void _enablePlatformOverrideForDesktop() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    }
  }
}

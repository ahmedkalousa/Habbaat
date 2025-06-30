import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/provider/space_units_provider.dart';

class ConnectivityHandler extends StatefulWidget {
  final Widget child;
  const ConnectivityHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<ConnectivityHandler> createState() => _ConnectivityHandlerState();
}

class _ConnectivityHandlerState extends State<ConnectivityHandler> {
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivitySubscription = _connectivityStream.listen((result) async {
      final isOnline = result != ConnectivityResult.none;
      final spaceUnitsProvider = Provider.of<SpaceUnitsProvider>(context, listen: false);
      final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);
      if (isOnline && _wasOffline) {
        await spaceUnitsProvider.fetchSpacesAndUnits(forceRefresh: true, isOnline: true);
        await spacesProvider.fetchSpacesAndUnits(forceRefresh: true, isOnline: true);
      } else if (!isOnline && !_wasOffline) {
        await spaceUnitsProvider.fetchSpacesAndUnits(forceRefresh: true, isOnline: false);
        await spacesProvider.fetchSpacesAndUnits(forceRefresh: true, isOnline: false);
      }
      _wasOffline = !isOnline;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 
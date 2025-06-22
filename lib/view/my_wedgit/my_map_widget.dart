import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class MyMapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String spaceName;
  final String spaceLocation;

  const MyMapWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.spaceName,
    required this.spaceLocation,
  }) : super(key: key);

  @override
  State<MyMapWidget> createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  MapController? _mapController;
  List<Marker> _markers = [];
  bool _isOnline = true;
  bool _isCheckingConnection = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkInternetConnection();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      print('Connectivity changed: $result');
      final isOnline = result != ConnectivityResult.none;
      
      if (_isOnline != isOnline) {
        setState(() {
          _isOnline = isOnline;
        });
        
        if (isOnline) {
          _createMarkers();
        }
      }
    });
  }

  Future<void> _checkInternetConnection() async {
    print('Checking internet connection...');
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      print('Connectivity result: $connectivityResult');
      
      setState(() {
        _isOnline = connectivityResult != ConnectivityResult.none;
        _isCheckingConnection = false;
      });
      
      print('Is online: $_isOnline');
      
      if (_isOnline) {
        _createMarkers();
      }
    } catch (e) {
      print('Error checking connectivity: $e');
      setState(() {
        _isOnline = false;
        _isCheckingConnection = false;
      });
    }
  }

  @override
  void didUpdateWidget(MyMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      if (_isOnline) {
        _createMarkers();
      }
    }
  }

  void _createMarkers() {
    _markers.clear();

    // إضافة علامة للمساحة إذا كانت الإحداثيات متوفرة
    if (widget.latitude != null && widget.longitude != null) {
      print('Creating marker at: ${widget.latitude}, ${widget.longitude}');
      _markers.add(
        Marker(
          point: LatLng(widget.latitude!, widget.longitude!),
          width: 60,
          height: 40,
          child: Column(
            children: [
              // اسم المساحة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  widget.spaceName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 1),
              // أيقونة الموقع البسيطة
              const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 20,
              ),
            ],
          ),
        ),
      );
    }
    
    print('Total markers: ${_markers.length}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('Building map widget - isChecking: $_isCheckingConnection, isOnline: $_isOnline');
    
    // إذا كان يفحص الاتصال
    if (_isCheckingConnection) {
      print('Showing loading state');
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'جاري فحص الاتصال...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // إذا لم يكن متصل بالإنترنت
    if (!_isOnline) {
      print('Showing offline state');
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              const Text(
                'لا يوجد اتصال بالإنترنت',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'تحتاج إلى اتصال بالإنترنت',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Text(
                'لمشاهدة موقع المساحة على الخريطة',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // إذا لم تكن الإحداثيات متوفرة
    if (widget.latitude == null || widget.longitude == null) {
      print('Showing no coordinates state');
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'إحداثيات الموقع غير متوفرة',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'سيتم إضافتها قريباً',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    debugPrint('Building map with ${_markers.length} markers');
    print('Showing map with coordinates: ${widget.latitude}, ${widget.longitude}');
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.latitude!, widget.longitude!),
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              enableMultiFingerGestureRace: false,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.work_spaces',
              maxZoom: 19,
            ),
            MarkerLayer(markers: _markers),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
} 
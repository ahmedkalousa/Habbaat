import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/view/my_page/space_details_page.dart';

class MyMapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String spaceName;
  final String spaceLocation;
  final List<Map<String, dynamic>>? locations;
  final bool isFullScreen;

  const MyMapWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.spaceName,
    required this.spaceLocation,
    this.locations,
    this.isFullScreen = false,
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
  Marker? _userMarker;

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

    if (widget.locations != null && widget.locations!.isNotEmpty) {
      for (final loc in widget.locations!) {
        if ((loc['lat'] is double || loc['lat'] is int) && (loc['lng'] is double || loc['lng'] is int)) {
          _markers.add(
            Marker(
              point: LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble()),
              width: 70.w,
              height: 50.h,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpaceDetailsPage(),
                                settings: RouteSettings(arguments: {'spaceId': loc['id']}),
                              ),
                            );
                          },
                          child: Text(
                            loc['name'] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'ID: ${loc['id']}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Icon(
                    Icons.location_on,
                    color: loc['color'] ?? Colors.red,
                    size: 25.sp,
                  ),
                ],
              ),
            ),
          );
        }
      }
      setState(() {});
      return;
    }

    // إضافة علامة للمساحة إذا كانت الإحداثيات متوفرة
    if (widget.latitude != null && widget.longitude != null) {
      print('Creating marker at: ${widget.latitude}, ${widget.longitude}');
      _markers.add(
        Marker(
          point: LatLng(widget.latitude!, widget.longitude!),
          width: 70.w,
          height: 50.h,
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 1.h),
              // أيقونة الموقع البسيطة
               Icon(
                Icons.location_on,
                color: Colors.red,
                size: 25.sp,
              ),
            ],
          ),
        ),
      );
    }
    
    print('Total markers: ${_markers.length}');
    setState(() {});
  }

  Future<bool> _checkAndRequestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفض إذن الموقع. لا يمكن تحديد موقعك.')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات الجهاز.'),
          action: SnackBarAction(
            label: 'الإعدادات',
            onPressed: () async {
              await Geolocator.openAppSettings();
            },
          ),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print('Building map widget - isChecking: $_isCheckingConnection, isOnline: $_isOnline');
    final double mapHeight = widget.isFullScreen ? MediaQuery.of(context).size.height : 200.h;
    
    // إذا كان يفحص الاتصال
    if (_isCheckingConnection) {
      print('Showing loading state');
      return Container(
        height: mapHeight,
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
        height: mapHeight,
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
        height: mapHeight,
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

    // جلب المساحات من المزود
    final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);
    final List<Map<String, dynamic>> exampleLocations = spacesProvider.spaces
        .where((s) => s.latitude != null && s.longitude != null && s.name != null && s.id != null &&
            s.latitude.toString().isNotEmpty && s.longitude.toString().isNotEmpty && s.name.toString().isNotEmpty && s.id.toString().isNotEmpty)
        .map((s) => {
              'id': s.id,
              'name': s.name,
              'lat': s.latitude,
              'long': s.longitude,
            })
        .toList();

    debugPrint('Building map with ${_markers.length} markers');
    print('Showing map with coordinates: ${widget.latitude}, ${widget.longitude}');
    return Stack(
      children: [
        Container(
          height: mapHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: exampleLocations.isNotEmpty && widget.isFullScreen
                    ? LatLng((exampleLocations[0]['lat'] as num).toDouble(), (exampleLocations[0]['long'] as num).toDouble())
                    : LatLng(widget.latitude ?? 31.5, widget.longitude ?? 34.47),
                initialZoom: widget.isFullScreen ? 10.0 : 15.0,
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
                MarkerLayer(
                  markers: [
                    ...exampleLocations.map((loc) => Marker(
                          point: LatLng((loc['lat'] as num).toDouble(), (loc['long'] as num).toDouble()),
                          width: 70.w,
                          height: 50.h,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    if (widget.isFullScreen)
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SpaceDetailsPage(),
                                        settings: RouteSettings(arguments: {'spaceId': loc['id']}),
                                      ),
                                    );
                                   
                                  },
                                  child: 
                                  widget.isFullScreen?
                                  Text(
                                    loc['name'].toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ): Text(
                                    widget.spaceName.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 25.sp,
                              ),
                            ],
                          ),
                        )),
                    if (_userMarker != null) _userMarker!,
                  ],
                ),
              ],
            ),
          ),
        ),
        if(widget.isFullScreen)
        Positioned(
          bottom: 85.h,
          right: 24.w,
          child: FloatingActionButton(
            heroTag: 'goToMyLocation',
            backgroundColor: Colors.white,
            child: Icon(Icons.my_location, color: Colors.blue),
            onPressed: () async {
              final allowed = await _checkAndRequestLocationPermission();
              if (!allowed) return;
              try {
                Position pos = await Geolocator.getCurrentPosition();
                final LatLng userLatLng = LatLng(pos.latitude, pos.longitude);
                setState(() {
                  _userMarker = Marker(
                    point: userLatLng,
                    width: 70.w,
                    height: 50.h,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          child: Text(
                            'انت',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 25.sp,
                        ),
                      ],
                    ),
                  );
                });
                _mapController?.move(userLatLng, 13);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تعذر تحديد موقعك: $e')),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
} 
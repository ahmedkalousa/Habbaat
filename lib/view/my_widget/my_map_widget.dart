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
import 'dart:io';

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
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) async {
      bool isOnline = result != ConnectivityResult.none;
      if (isOnline) {
        try {
          final lookup = await InternetAddress.lookup('google.com');
          isOnline = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
        } catch (_) {
          isOnline = false;
        }
      }
      if (_isOnline != isOnline) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  Future<void> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      bool isOnline = connectivityResult != ConnectivityResult.none;
      if (isOnline) {
        try {
          final result = await InternetAddress.lookup('google.com');
          isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } catch (_) {
          isOnline = false;
        }
      }
      setState(() {
        _isOnline = isOnline;
        _isCheckingConnection = false;
      });
    } catch (e) {
      setState(() {
        _isOnline = false;
        _isCheckingConnection = false;
      });
    }
  }

  List<Map<String, dynamic>> _getSpacesWithCoordinates() {
    final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);
    return spacesProvider.spaces
        .where((space) => 
            space.latitude != null && 
            space.longitude != null &&
            space.latitude != 0.0 && 
            space.longitude != 0.0)
        .map((space) => {
              'id': space.id,
              'name': space.name,
              'lat': space.latitude,
              'lng': space.longitude,
              'governorate': space.governorate,
            })
        .toList();
  }

  LatLng _getDefaultCenter() {
    final spacesWithCoords = _getSpacesWithCoordinates();
    if (spacesWithCoords.isNotEmpty) {
      double totalLat = 0.0;
      double totalLng = 0.0;
      for (final space in spacesWithCoords) {
        totalLat += (space['lat'] as num).toDouble();
        totalLng += (space['lng'] as num).toDouble();
      }
      return LatLng(totalLat / spacesWithCoords.length, totalLng / spacesWithCoords.length);
    }
    return LatLng(31.5017, 34.4668); // مدينة غزة
  }

  Future<bool> _checkAndRequestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم رفض إذن الموقع. لا يمكن تحديد موقعك.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            backgroundColor: Colors.red.withOpacity(0.9),
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات الجهاز.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          backgroundColor: Colors.red.withOpacity(0.9),
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'الإعدادات',
            textColor: Colors.white,
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
    final double mapHeight = widget.isFullScreen ? MediaQuery.of(context).size.height : 200.h;

    if (!_isOnline || _isCheckingConnection) {
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
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('لا يوجد اتصال بالإنترنت', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    try {
      final spacesWithCoords = _getSpacesWithCoordinates();
      final defaultCenter = _getDefaultCenter();
      
      print('Building map with ${spacesWithCoords.length} spaces with coordinates');
      
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
                  initialCenter: defaultCenter,
                  initialZoom: widget.isFullScreen ? 10.5 : 15.0,
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
                      ...spacesWithCoords.map((space) => Marker(
                            point: LatLng((space['lat'] as num).toDouble(), (space['lng'] as num).toDouble()),
                            width: 100.w,
                            height: 80.h,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(6.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (widget.isFullScreen) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SpaceDetailsPage(),
                                            settings: RouteSettings(arguments: {'spaceId': space['id']}),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      space['name'].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 32.sp,
                                ),
                              ],
                            ),
                          )),
                      
                      if (Provider.of<SpacesProvider>(context).isUserLocationSet && widget.isFullScreen)
                        Marker(
                          point: Provider.of<SpacesProvider>(context).userLocation!,
                          width: 80.w,
                          height: 60.h,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                                child: Text(
                                  'انت',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
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
                                size: 30.sp,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (spacesWithCoords.isEmpty && widget.isFullScreen)
            Positioned(
              top: 20.h,
              left: 20.w,
              right: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 20.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'لا توجد مساحات متاحة حالياً.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (widget.isFullScreen)
            Positioned(
              bottom: 90.h,
              right: 24.w,
              child: FloatingActionButton(
                heroTag: 'goToMyLocation',
                backgroundColor: Colors.white,
                child: Icon(Icons.my_location, color: Colors.blue),
                onPressed: () async {
                  // إظهار مؤشر التحميل
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text('جاري تحديد موقعك...', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                        ],
                      ),
                      backgroundColor: Colors.blue.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  final allowed = await _checkAndRequestLocationPermission();
                  if (!allowed) return;
                  
                  final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);
                  spacesProvider.setGettingLocation(true);
                  
                  try {
                    // التحقق من تفعيل خدمة الموقع
                    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('خدمة الموقع معطلة. يرجى تفعيل GPS من إعدادات الجهاز.'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          backgroundColor: Colors.orange.withOpacity(0.9),
                          duration: Duration(seconds: 4),
                          action: SnackBarAction(
                            label: 'الإعدادات',
                            textColor: Colors.white,
                            onPressed: () async {
                              await Geolocator.openLocationSettings();
                            },
                          ),
                        ),
                      );
                      return;
                    }

                    Position pos = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                      timeLimit: Duration(seconds: 15),
                    );
                    
                    final LatLng userLatLng = LatLng(pos.latitude, pos.longitude);
                    spacesProvider.setUserLocation(userLatLng);
                    _mapController?.move(userLatLng, 15.0);
                    
                    // رسالة نجاح
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم تحديد موقعك بنجاح!'),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),                    
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        backgroundColor: Colors.green.withOpacity(0.9),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    
                  } catch (e) {
                    print('Error getting location: $e');
                    String errorMessage = 'تعذر تحديد موقعك. تأكد من تفعيل GPS ووجود اتصال بالإنترنت.';
                    
                    if (e.toString().contains('PERMISSION_DENIED')) {
                      errorMessage = 'تم رفض إذن الموقع. يرجى السماح للتطبيق بالوصول إلى موقعك.';
                    } else if (e.toString().contains('LOCATION_SERVICE_DISABLED')) {
                      errorMessage = 'خدمة الموقع معطلة. يرجى تفعيل GPS من إعدادات الجهاز.';
                    } else if (e.toString().contains('NO_GPS_AVAILABLE')) {
                      errorMessage = 'لا يوجد GPS متاح. تأكد من وجود إشارة GPS قوية.';
                    } else if (e.toString().contains('timeout')) {
                      errorMessage = 'انتهت مهلة تحديد الموقع. تأكد من وجود إشارة GPS قوية وحاول مرة أخرى.';
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        backgroundColor: Colors.red.withOpacity(0.9),
                        duration: Duration(seconds: 4),
                        action: SnackBarAction(
                          label: 'الإعدادات',
                          textColor: Colors.white,
                          onPressed: () async {
                            await Geolocator.openAppSettings();
                          },
                        ),
                      ),
                    );
                  } finally {
                    spacesProvider.setGettingLocation(false);
                  }
                },
              ),
            ),
        ],
      );
    } catch (e) {
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
              Icon(Icons.wifi_off, size: 48, color: Colors.orange),
              SizedBox(height: 8),
              Text('تعذر تحميل الخريطة', style: TextStyle(color: Colors.orange, fontSize: 12)),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
} 
import 'package:flutter/material.dart';
import 'package:work_spaces/view/my_wedgit/my_map_widget.dart';

class MapPage extends StatefulWidget {
  static const String id = 'MapPage';
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  var locations = [
           {
              'name': 'مساحة غزة',
              'lat': 31.5,
              'lng': 34.47,
              'color': Colors.red,
            },
            {
              'name': 'مساحة خانيونس',
              'lat': 31.34,
              'lng': 34.30,
              'color': Colors.blue,
            },
            {
              'name': 'مساحة رفح',
              'lat': 31.28,
              'lng': 34.24,
              'color': Colors.green,
            },
            ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyMapWidget(
        locations: locations,
        latitude: locations[0]['lat'] as double,
        longitude: locations[0]['lng'] as double,
        spaceName: '',
        spaceLocation: '',
        isFullScreen: true,
      ),
    );
  }
}
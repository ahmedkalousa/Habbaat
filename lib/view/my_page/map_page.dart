import 'package:flutter/material.dart';
import 'package:work_spaces/view/my_widget/my_map_widget.dart';

class MapPage extends StatefulWidget {
  static const String id = 'MapPage';
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyMapWidget(
        latitude: 3.5,
        longitude: 5.6,
        spaceName: '',
        spaceLocation: '',
        isFullScreen: true,
      ),
    );
  }
}
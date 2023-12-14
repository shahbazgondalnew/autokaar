import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final CameraPosition initialCameraPosition;

  const MapScreen({required this.initialCameraPosition});

  static Future<LatLng?> pickLocationFromMap(
      BuildContext context, CameraPosition initialCameraPosition) async {
    final selectedCameraPosition = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialCameraPosition: initialCameraPosition,
        ),
      ),
    );

    if (selectedCameraPosition != null) {
      return LatLng(
        selectedCameraPosition.target.latitude,
        selectedCameraPosition.target.longitude,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        onTap: (LatLng location) {
          // Handle when the user taps on the map to select a location
          Navigator.pop(context, CameraPosition(target: location));
        },
      ),
    );
  }
}

import 'package:autokaar/userMod/booking.dart';
import 'package:autokaar/userMod/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class NearbyGaragesScreen extends StatefulWidget {
  @override
  _NearbyGaragesScreenState createState() => _NearbyGaragesScreenState();
}

class _NearbyGaragesScreenState extends State<NearbyGaragesScreen> {
  GoogleMapController? _mapController;
  List<Marker> _markers = [];
  LatLng? _userLocation; // User's location coordinates

  @override
  void initState() {
    super.initState();
    getUserLocation(); // Call this method to get user location
    fetchMechanics(); // Call this method to fetch mechanics
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mechanic'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    31.5204,
                    73.0562,
                  ), // Set your initial map center coordinates for Faisalabad
                  zoom: 12,
                ),
                markers: Set<Marker>.from(_markers),
                myLocationEnabled: true, // Display the blue location circle
                myLocationButtonEnabled: true, // Enable the my location button
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _markers.length,
              itemBuilder: (context, index) {
                final marker = _markers[index];
                final distance = calculateDistance(
                    marker.position.latitude, marker.position.longitude);
                return Container(
                  margin:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Colors.black, Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        Icons.chat,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _navigateToChatScreen(marker.markerId.value);
                      },
                    ),
                    title: Text(
                      marker.infoWindow.title ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${distance.toStringAsFixed(2)} km away',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _navigateToBookingScreen(marker.markerId.value);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Book'),
                    ),
                    onTap: () {
                      _navigateToGarageLocation(marker.position);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchMechanics() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('mechanicGarage').get();

      setState(() {
        _markers = snapshot.docs.map((DocumentSnapshot document) {
          final data = document.data() as Map<String, dynamic>;
          final garageName = data['garageName'] ?? '';
          final googleLocation = data['googleLocation'];

          double latitude = 0;
          double longitude = 0;

          if (googleLocation is GeoPoint) {
            latitude = googleLocation.latitude;
            longitude = googleLocation.longitude;
          } else if (googleLocation is Map<String, dynamic>) {
            latitude = googleLocation['latitude']?.toDouble() ?? 0.0;
            longitude = googleLocation['longitude']?.toDouble() ?? 0.0;
          }

          return Marker(
            markerId: MarkerId(document.id),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
                title:
                    garageName), // Set the garage name as the info window title
            onTap: () {
              _navigateToGarageLocation(LatLng(latitude, longitude));
            },
          );
        }).toList();
      });
    } catch (err) {
      print('Failed to fetch mechanic data: $err');
    }
  }

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(_userLocation!));
        }
      });
    } catch (err) {
      print('Failed to get user location: $err');
    }
  }

  double calculateDistance(double latitude, double longitude) {
    if (_userLocation != null) {
      final userLatitude = _userLocation!.latitude;
      final userLongitude = _userLocation!.longitude;
      return Geolocator.distanceBetween(
            userLatitude,
            userLongitude,
            latitude,
            longitude,
          ) /
          1000; // Convert to kilometers
    }
    return 0;
  }

  void _navigateToGarageLocation(LatLng position) {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(position));
    }
  }

  void _navigateToChatScreen(String garageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(garageId: garageId),
      ),
    );
  }

  void _navigateToBookingScreen(String garageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(garageId: garageId),
      ),
    );
  }
}

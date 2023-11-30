import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MechanicMapScreen extends StatefulWidget {
  @override
  _MechanicMapScreenState createState() => _MechanicMapScreenState();
}

class _MechanicMapScreenState extends State<MechanicMapScreen> {
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
        title: Text('Mechanic Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(31.5204,
              73.0562), // Set your initial map center coordinates for Faisalabad
          zoom: 12,
        ),
        markers: Set<Marker>.from(_markers),
        myLocationEnabled: true, // Display the blue location circle
        myLocationButtonEnabled: true, // Enable the my location button
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
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
            onTap: () {
              // Handle the marker tap event
              _showGarageDetailsDialog(garageName, document.id);
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

  void _showGarageDetailsDialog(String garageName, String garageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<void>(
          future: showMechanicServices(garageName, garageId),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            return AlertDialog(
              title: Text(garageName),
              content: snapshot.connectionState == ConnectionState.waiting
                  ? CircularProgressIndicator()
                  : null, // Show a loading indicator if needed
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> showMechanicServices(String garageName, String garageId) async {
    try {
      DocumentSnapshot addedServiceSnapshot = await FirebaseFirestore.instance
          .collection('addedService')
          .doc(garageId)
          .get();

      if (addedServiceSnapshot.exists) {
        Map<String, dynamic>? addedServiceData =
        addedServiceSnapshot.data() as Map<String, dynamic>?;

        if (addedServiceData != null && addedServiceData.containsKey('services')) {
          Map<String, dynamic> serviceData =
          Map<String, dynamic>.from(addedServiceData['services'] as Map);

          List<Service> fetchedServices = [];

          for (String serviceId in serviceData.keys) {
            int price = serviceData[serviceId]['servicePrice'] ?? 0;
            int timeTaken = serviceData[serviceId]['timeTaken'] ?? 0;

            // Fetch the service name from the 'mechanicService' collection
            DocumentSnapshot serviceSnapshot = await FirebaseFirestore.instance
                .collection('mechanicService')
                .doc(serviceId)
                .get();

            String serviceName = '';
            if (serviceSnapshot.exists) {
              serviceName = serviceSnapshot.get('serviceName');
            }

            fetchedServices.add(
              Service(
                id: serviceId,
                serviceName: serviceName,
                price: price.toDouble(),
                performServiceTime: timeTaken,
              ),
            );
          }

          // Display the services in the alert dialog content
          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(garageName),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: fetchedServices.map((service) {
                    return Text(
                      '${service.serviceName}: PKR ${service.price.toStringAsFixed(2)} (${service.performServiceTime} mins)',
                    );

                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (error) {
      print('Error fetching mechanic services: $error');
    }
  }



}
class Service {
  final String id;
  final String serviceName;
  final double price;
  final int performServiceTime;

  Service({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.performServiceTime,
  });
}

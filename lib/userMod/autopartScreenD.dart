import 'package:autokaar/userMod/quantitySelect.dart';
import 'package:autokaar/userMod/showPartUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import the Autopart class
import 'package:maps_launcher/maps_launcher.dart';

class AutopartDetailsScreen extends StatefulWidget {
  final Autopart autopart;

  AutopartDetailsScreen({required this.autopart});

  @override
  _AutopartDetailsScreenState createState() => _AutopartDetailsScreenState();
}

class _AutopartDetailsScreenState extends State<AutopartDetailsScreen> {
  late String garageName = 'Loading...';
  double latitude = 31.5497;
  double longitude = 73.0782;
  late GoogleMapController mapController;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    fetchGarageDetails();
  }

  void _openGoogleMapsDirections() {
    MapsLauncher.launchCoordinates(
      latitude,
      longitude,
      garageName,
    );
  }

  Future<void> fetchGarageDetails() async {
    try {
      // Replace 'mechanicGarage' with your actual Firestore collection name
      final garageSnapshot = await FirebaseFirestore.instance
          .collection('mechanicGarage')
          .doc(widget.autopart.garageID)
          .get();

      if (garageSnapshot.exists) {
        final garageData = garageSnapshot.data() as Map<String, dynamic>;
        setState(() {
          garageName = garageData['garageName'] ?? 'Not Found';
          final googleLocation = garageData['googleLocation'];
          if (googleLocation != null &&
              googleLocation['latitude'] != null &&
              googleLocation['longitude'] != null) {
            latitude = googleLocation['latitude'];
            longitude = googleLocation['longitude'];
          }

          // Add other fields as needed
        });
      } else {
        setState(() {
          garageName = 'Not Found';

          // Set other fields to default values
        });
      }
    } catch (e) {
      print('Error fetching garage details: $e');
      setState(() {
        garageName = 'Not Found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Autopart Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${widget.autopart.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Image.network(
              widget.autopart.image,
              fit: BoxFit.cover,
              height: 200.0,
            ),
            SizedBox(height: 16.0),
            Text(
              'Category: ${widget.autopart.category}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Subcategory: ${widget.autopart.subcategory}',
              style: TextStyle(fontSize: 16),
            ),
            // ... (other details)
            // ... (other details)
            SizedBox(height: 8.0),
            Text(
              'Quantity: ${widget.autopart.quantity}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Price: ${widget.autopart.price} RS',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),

            Text(
              'Garage: $garageName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Container(
              height: 200, // adjust the height as needed
              child: GoogleMap(
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      latitude, longitude), // use the actual lat and long
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('garageLocation'),
                    position: LatLng(latitude, longitude),
                    infoWindow: InfoWindow(title: garageName),
                  ),
                },
              ),
            ),
            QuantitySelector(
              initialQuantity: quantity,
              onChanged: (newQuantity) {
                setState(() {
                  quantity = newQuantity;
                });
              },
            ),
            ElevatedButton(
              onPressed: _openGoogleMapsDirections,
              child: Text('Get Directions'),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _placeOrder,
            child: Text('Place Order'),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    final User? user = FirebaseAuth.instance.currentUser;
    try {
      // Your existing code to fetch garage details
      // ...

      // Create a new order object

      final order = {
        'name': widget.autopart.name,
        'category': widget.autopart.category,
        'subcategory': widget.autopart.subcategory,
        'image': widget.autopart.image,
        'quantity': quantity,
        'price': widget.autopart.price,
        'garageID': widget.autopart.garageID,
        'status': 'Pending',
        'userID': user?.uid, // Replace with actual UID
        // Add other fields as needed
      };

      // Add the order to the 'autopartOrder' collection
      await FirebaseFirestore.instance.collection('autopartOrder').add(order);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully')),
      );
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order')),
      );
    }
  }
}

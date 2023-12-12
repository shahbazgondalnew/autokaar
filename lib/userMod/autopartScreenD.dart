import 'package:autokaar/mechanicMod/showAutoparts.dart';
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
        setState(() { //Location based on longitude latitude
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
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: ${widget.autopart.name}',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    widget.autopart.image,
                    fit: BoxFit.cover,
                    height: 200.0,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ListTile(
                    leading: Icon(Icons.category, color: Colors.white),
                    title: Text(
                      'Category: ${widget.autopart.category}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.subdirectory_arrow_right,
                        color: Colors.white),
                    title: Text(
                      'Subcategory: ${widget.autopart.subcategory}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.add_shopping_cart, color: Colors.white),
                    title: Text(
                      'Quantity: ${widget.autopart.quantity}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.monetization_on, color: Colors.white),
                    title: Text(
                      'Price: ${widget.autopart.price} RS',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.white),
                    title: Text(
                      'Garage: $garageName',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _openGoogleMapsDirections,
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  padding: EdgeInsets.all(16.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 24.0, color: Colors.black),
                    SizedBox(width: 8.0),
                    Text(
                      'Get Directions',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.green, // Change the background color to green
              onPrimary: Colors.white, // Button text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              elevation: 5, // Button elevation
              minimumSize: Size(double.infinity, 0), // Full width
            ),
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
        'userID': user?.uid,
        'averageLife': widget.autopart.averageLife
        // Replace with actual UID
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

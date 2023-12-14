import 'package:autokaar/mechanicMod/mechanicEditParts.dart';
import 'package:autokaar/userMod/carDetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerformAppointment extends StatefulWidget {
  final Map<String, dynamic> appointmentData; // Pass appointment data here
  final String garageId; // Pass garageId here

  PerformAppointment({required this.appointmentData, required this.garageId});

  @override
  _PerformAppointmentState createState() => _PerformAppointmentState();
}

class _PerformAppointmentState extends State<PerformAppointment> {
  int totalServicePrice = 0; // Maintain total price in the state
  int totalServiceTime = 0;

  @override
  void initState() {
    super.initState();
    calculateTotalPriceAndTime();
  }

  Future<Map<String, dynamic>> fetchServiceDetails(String serviceId) async {
    final DocumentSnapshot addedServiceSnapshot = await FirebaseFirestore
        .instance
        .collection('addedService')
        .doc(widget.garageId)
        .get();

    if (!addedServiceSnapshot.exists) {
      return {}; // Handle the case where addedService data doesn't exist
    }

    final Map<String, dynamic> addedServiceData =
        addedServiceSnapshot.data() as Map<String, dynamic>;

    final Map<String, dynamic> serviceDetails =
        addedServiceData['services'][serviceId];

    // Fetch service name from 'mechanicService' collection
    final DocumentSnapshot mechanicServiceSnapshot = await FirebaseFirestore
        .instance
        .collection('mechanicService')
        .doc(serviceId)
        .get();

    if (!mechanicServiceSnapshot.exists) {
      return {}; // Handle the case where mechanicService data doesn't exist
    }

    final Map<String, dynamic> mechanicServiceData =
        mechanicServiceSnapshot.data() as Map<String, dynamic>;

    final String serviceName = mechanicServiceData['serviceName'] ?? '';

    // Merge the service name with the service details
    serviceDetails['serviceName'] = serviceName;

    return serviceDetails;
  }

  Future<void> calculateTotalPriceAndTime() async {
    int totalPrice = 0;
    int totalTime = 0;

    final List<dynamic> selectedServiceData =
        widget.appointmentData['services'] ?? [];

    for (final dynamic item in selectedServiceData) {
      final String serviceId = item.toString();
      final Map<String, dynamic> serviceDetails =
          await fetchServiceDetails(serviceId);

      final int servicePrice = serviceDetails['servicePrice'] ?? 0;
      final int serviceTime = serviceDetails['timeTaken'] ?? 0;

      totalPrice += servicePrice;
      totalTime += serviceTime;
    }

    setState(() {
      totalServicePrice = totalPrice;
      totalServiceTime = totalTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Services:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Fetch selected services from appointment data and display them
            buildSelectedServicesList(),
            // Display total price and total time
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price: \$${totalServicePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total Time Taken: $totalServiceTime mins',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Other content for the PerformAppointment screen
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Time and Total Price

            SizedBox(height: 16),
            // Confirm Booking Button
            ElevatedButton(
              onPressed: () {
                print("XXXXXXXXXXXXX");
                print(widget.appointmentData['carId']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarLogScreenMechanic(
                        carID: widget.appointmentData['carId'],
                        appointmentData: widget.appointmentData,
                        garageID: widget.garageId),
                  ),
                );
              },
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text(
                    'Complete Appointment',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the list of selected services
  Widget buildSelectedServicesList() {
    final List<dynamic> selectedServiceData =
        widget.appointmentData['services'] ?? [];

    final List<Widget> serviceWidgets = selectedServiceData.map((dynamic item) {
      final String serviceId = item.toString();
      return FutureBuilder<Map<String, dynamic>>(
        future: fetchServiceDetails(serviceId),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print(
                'Service data not found for $serviceId'); // Debugging statement
            return Text('Service not found');
          }

          final Map<String, dynamic> serviceData = snapshot.data!;
          final int servicePrice = serviceData['servicePrice'] ?? 0;
          final int serviceTime = serviceData['timeTaken'] ?? 0;
          final String serviceName = serviceData['serviceName'] ?? '';

          // Debugging statements to check service data
          print('Service Name: $serviceName');
          print('Service Price: $servicePrice');
          print('Service Time: $serviceTime');

          // Build a ListTile or any other widget to display the service information
          return ListTile(
            title: Text(serviceName),
            subtitle: Text(
              'Price: \$${servicePrice.toStringAsFixed(2)}\nTime Taken: $serviceTime mins',
            ),
          );
        },
      );
    }).toList();

    return Column(
      children: serviceWidgets,
    );
  }
}

import 'package:autokaar/mechanicMod/showAppointmentMechanicX.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CheckOutAppointment extends StatefulWidget {
  final Map<String, dynamic> appointmentData; // Pass appointment data here
  final String garageId; // Pass garageId here

  CheckOutAppointment({required this.appointmentData, required this.garageId});

  @override
  _CheckOutAppointmentState createState() => _CheckOutAppointmentState();
}

class _CheckOutAppointmentState extends State<CheckOutAppointment> {
  int totalServicePrice = 0; // Maintain total price in the state
  int totalServiceTime = 0;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    calculateTotalPriceAndTime();
  }
  Future<void> storePaymentStatus() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final Map<String, dynamic> paymentData = {
        'isPaid': isPaid,
        'totalPrice': totalServicePrice,
        'totalTime': totalServiceTime,
        'services': widget.appointmentData['services'],
        'endTime': widget.appointmentData['endTime'],
        'userId': widget.appointmentData['userUid'],
        'carId': widget.appointmentData['carId'],
        'garageId': widget.appointmentData['garageId'],
        'appointmentData': widget.appointmentData,
      };

      // Generate a unique appointmentId
      final String appointmentId = Uuid().v4();
      paymentData['appointmentId'] = appointmentId;

      await firestore.collection('paymentStatus').doc(appointmentId).set(paymentData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment status has been saved to Firebase.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving payment status: $error'),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> fetchServiceDetails(String serviceId) async {
    // Fetch service price and time from 'addedService' collection
    final DocumentSnapshot addedServiceSnapshot = await FirebaseFirestore.instance
        .collection('addedService')
        .doc(widget.garageId)
        .get();

    if (!addedServiceSnapshot.exists) {
      return {}; // Handle the case where addedService data doesn't exist
    }

    final Map<String, dynamic> addedServiceData = addedServiceSnapshot.data()
    as Map<String, dynamic>;

    final Map<String, dynamic> serviceDetails =
    addedServiceData['services'][serviceId];

    // Fetch service name from 'mechanicService' collection
    final DocumentSnapshot mechanicServiceSnapshot = await FirebaseFirestore.instance
        .collection('mechanicService')
        .doc(serviceId)
        .get();

    if (!mechanicServiceSnapshot.exists) {
      return {}; // Handle the case where mechanicService data doesn't exist
    }

    final Map<String, dynamic> mechanicServiceData = mechanicServiceSnapshot.data()
    as Map<String, dynamic>;

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
        title: Text('Bill'),
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

            buildSelectedServicesList(),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                ' PKR ${totalServicePrice.toStringAsFixed(2)}', // Display in PKR
                style: TextStyle(
                  fontSize: 48.0, // Increase the font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Paid Checkbox
            Row(
              children: [
                Text(
                  'Paid: ',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                Checkbox(
                  value: isPaid,
                  onChanged: (value) {
                    setState(() {
                      isPaid = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            // Confirm Booking Button
            ElevatedButton(
              onPressed: () {
                storePaymentStatus();
                print(widget.appointmentData);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentListScreen(garageId: widget.garageId,),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 5,
                minimumSize: Size(double.infinity, 0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text(
                    'Proceed',
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


  Widget buildSelectedServicesList() {
    final List<dynamic> selectedServiceData = widget.appointmentData['services'] ?? [];

    final List<Widget> serviceWidgets = selectedServiceData
        .map((dynamic item) {
      final String serviceId = item.toString();
      return FutureBuilder<Map<String, dynamic>>(
        future: fetchServiceDetails(serviceId),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('Service data not found for $serviceId'); // Debugging statement
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


          return ListTile(
            title: Text(serviceName),
            subtitle: Text(
              'Price: \$${servicePrice.toStringAsFixed(2)}\nTime Taken: $serviceTime mins',
            ),
          );
        },
      );
    })
        .toList();

    return Column(
      children: serviceWidgets,
    );
  }
}

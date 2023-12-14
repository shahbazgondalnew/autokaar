import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final String? appointmentID;

  AppointmentDetailsScreen({required this.appointmentID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookedservice')
            .doc(appointmentID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final Map<String, dynamic>? appointmentData =
                snapshot.data?.data() as Map<String, dynamic>?;

            if (appointmentData != null) {
              final String? garageID = appointmentData['garageID']?.toString();

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('mechanicGarage')
                    .doc(garageID)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error retrieving garage data.'));
                  }

                  final garageData =
                      snapshot.data?.data() as Map<String, dynamic>?;

                  if (garageData != null) {
                    final String? garageName =
                        garageData['garageName']?.toString();
                    final String? latitude =
                        garageData['googleLocation']['latitude']?.toString();
                    final String? longitude =
                        garageData['googleLocation']['longitude']?.toString();
                    final String? imageUrl = garageData['imageUrl']?.toString();

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Garage: $garageName',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (imageUrl != null)
                            Container(
                              width: 200,
                              height: 200,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                              alignment: Alignment.center,
                            ),
                          ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text('Garage Status'),
                            subtitle: Text(
                              '${garageData['statusOfGarage'] ?? ''}',
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.directions),
                            title: Text('Get Directions'),
                            onTap: () {
                              if (latitude != null && longitude != null) {
                                String mapsUrl =
                                    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                                launch(mapsUrl);
                              }
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete Appointment'),
                            onTap: () {
                              // Perform delete appointment logic here
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                      'Are you sure you want to delete this appointment?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          // Get the reference to the appointment document
                                          DocumentReference appointmentRef =
                                              FirebaseFirestore.instance
                                                  .collection('bookedservice')
                                                  .doc(appointmentID);

                                          appointmentRef.delete().then((value) {
                                            print(
                                                'Appointment deleted successfully');
                                          }).catchError((error) {
                                            print(
                                                'Failed to delete appointment: $error');
                                          });

                                          Navigator.pop(context);
                                        },
                                        child: Text('Delete'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(child: Text('Garage data not found.'));
                  }
                },
              );
            } else {
              return Center(child: Text('Appointment data not found.'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error retrieving appointment data.'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

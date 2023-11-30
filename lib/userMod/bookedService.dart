import 'package:autokaar/userMod/appointmentview.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booked Services'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookedservice')
            .where('userID', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            if (documents.isEmpty) {
              return Center(
                child: Text('No booked services found.'),
              );
            } else {
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic>? serviceData =
                      documents[index].data() as Map<String, dynamic>?;

                  if (serviceData != null) {
                    final List<dynamic>? services =
                        serviceData['services'] as List<dynamic>?;
                    final Timestamp? timestamp =
                        serviceData['date'] as Timestamp?;
                    final String? timeString = serviceData['time']?.toString();
                    final String? garageID =
                        serviceData['garageID']?.toString();

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('mechanicGarage')
                          .doc(garageID)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(); // Show a placeholder or loading indicator
                        }

                        if (snapshot.hasError) {
                          return Text('Error retrieving garage data.');
                        }

                        final garageData =
                            snapshot.data?.data() as Map<String, dynamic>?;

                        if (garageData != null) {
                          final String? garageName =
                              garageData['garageName']?.toString();
                          final String? imageUrl =
                              garageData['imageUrl']?.toString();

                          DateTime? date;
                          if (timestamp != null) {
                            date = timestamp.toDate();
                          }

                          TimeOfDay? time;
                          if (timeString != null) {
                            final String formattedTime =
                                timeString.substring(10, timeString.length - 1);
                            final List<String> timeParts =
                                formattedTime.split(':');
                            final int hour = int.parse(timeParts[0]);
                            final int minute = int.parse(timeParts[1]);

                            time = TimeOfDay(hour: hour, minute: minute);
                          }

                          return GestureDetector(
                            onTap: () {
                              String? appointmentID = documents[index].id;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AppointmentDetailsScreen(
                                    appointmentID: appointmentID ?? '',
                                  ),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
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
                              margin: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              padding: EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    imageUrl ?? '',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Garage Name: ${garageName ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Date: ${date != null ? DateFormat.yMMMd().format(date) : 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Time: ${time != null ? time.format(context) : 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Services:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        if (services != null)
                                          for (var service in services)
                                            Text(
                                              '- $service',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Perform actions when "Set Reminder" is tapped
                                          },
                                          child: Text('Set Reminder'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error retrieving booked services.'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

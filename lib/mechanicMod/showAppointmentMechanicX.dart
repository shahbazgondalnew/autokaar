import 'package:autokaar/mechanicMod/perform_appointment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentListScreen extends StatelessWidget {
  final String garageId;

  AppointmentListScreen({required this.garageId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
      ),
      body: AppointmentList(garageId: garageId),
    );
  }
}

class AppointmentList extends StatelessWidget {
  final String garageId;
  String userName = "loading";

  AppointmentList({required this.garageId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Bookedappointments')
          .where('garageId', isEqualTo: garageId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print("Error fetching data: ${snapshot.error}");
          return Center(
            child: Text('Error fetching data. Please try again later.'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No booked appointments for Garage '),
          );
        }

        final appointments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment =
                appointments[index].data() as Map<String, dynamic>;

            // Wrap the ListTile with GestureDetector
            return GestureDetector(
              onTap: () {
                print("YYYYYYYYYYYY");
                print(appointment);
                // Navigate to PerformAppointment screen and pass appointment data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerformAppointment(
                      appointmentData: appointment,
                      garageId: garageId,
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
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
                  title: FutureBuilder<String>(
                    future: fetchUserName(appointment['userUid']),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Loading...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        );
                      }

                      final userName = snapshot.data ?? "User";

                      return Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      );
                    },
                  ),
                  subtitle: Text(
                    'Start Time: ${appointment['startTime']}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String> fetchUserName(String userId) async {
    // Fetch user name from the 'Users' collection
    final DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (!userSnapshot.exists) {
      return "User"; // Return a default value in case user data doesn't exist
    }

    final Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>;

    final String userName = userData['name'] ?? '';

    return userName;
  }
}

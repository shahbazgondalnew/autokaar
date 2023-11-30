import 'package:autokaar/mechanicMod/mechanicPaymentLog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectGarage extends StatelessWidget {
  final String userId;

  SelectGarage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Garage'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mechanicGarage')
            .where('userID', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading data. Please try again later.'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('You have not added any garages yet.'),
            );
          }

          final garageDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: garageDocs.length,
            itemBuilder: (context, index) {
              final garageData = garageDocs[index].data() as Map<String, dynamic>;
              final garageName = garageData['garageName'] as String;
              final garageId = garageDocs[index].id;

              return GestureDetector(
                onTap: () {
                  // Navigate to AppointmentListScreen with the selected garage's ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentDataListScreen(garageId: garageId),
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
                    title: Text(
                      garageName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white, // Text color
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white, // Icon color
                    ),
                  ),
                ),
              );

            },
          );
        },
      ),
    );
  }


}
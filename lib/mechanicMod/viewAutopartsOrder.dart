import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatefulWidget {
  final String garageId;

  OrdersScreen({required this.garageId});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders for Garage'),
      ),
      body: Column(
        children: [
          _buildFilterDropdown(),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('autopartOrder')
                  .where('garageID', isEqualTo: widget.garageId)
                  .where('status',
                      isEqualTo:
                          selectedFilter == 'All' ? null : selectedFilter)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No orders found for this garage'),
                  );
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    return OrderCard(
                      data: data,
                      onUpdateStatus: (String newStatus) {
                        // No need to manually update the status here,
                        // as it's already updated in the OrderCard widget
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<String>(
        value: selectedFilter,
        onChanged: (value) {
          setState(() {
            selectedFilter = value!;
          });
        },
        items: ['All', 'Pending', 'Working', 'Done']
            .map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                ))
            .toList(),
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String) onUpdateStatus;

  OrderCard({required this.data, required this.onUpdateStatus});

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.data['status'] ?? 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.data['name'] ?? ''),
        subtitle: Text('Quantity: ${widget.data['quantity']}'),
        trailing: DropdownButton<String>(
          value: selectedStatus,
          onChanged: (value) {
            setState(() {
              selectedStatus = value!;
              widget.onUpdateStatus(selectedStatus);
            });
          },
          items: ['Pending', 'Working', 'Done']
              .map((status) => DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class MyGaragesScreenPart extends StatelessWidget {
  String getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      // Handle the case when the user is not logged in
      throw Exception("User is not logged in.");
    }
  }

  MyGaragesScreenPart();

  @override
  Widget build(BuildContext context) {
    String userId = getCurrentUserUid();
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
              final garageData =
                  garageDocs[index].data() as Map<String, dynamic>;
              final garageName = garageData['garageName'] as String;
              final garageId = garageDocs[index].id;

              return GestureDetector(
                onTap: () {
                  // Navigate to AppointmentListScreen with the selected garage's ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdersScreen(garageId: garageId),
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

import 'package:autokaar/commonMod/blogOptionScreen.dart';
import 'package:autokaar/mechanicMod/addGarage.dart';
import 'package:autokaar/mechanicMod/appointmentMechanicView.dart';
import 'package:autokaar/mechanicMod/garageSet.dart';
import 'package:autokaar/mechanicMod/locationGarage.dart';
import 'package:autokaar/mechanicMod/mechanicChat.dart';
import 'package:autokaar/mechanicMod/selectGarage.dart';
import 'package:autokaar/mechanicMod/showAppointmentMechanicX.dart';
import 'package:autokaar/mechanicMod/showAutoparts.dart';
import 'package:autokaar/mechanicMod/showMechanic.dart';
import 'package:autokaar/mechanicMod/viewAutopartsOrder.dart';
import 'package:autokaar/userMod/mainScreenApp.dart';
import 'package:autokaar/commonMod/userProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../commonMOd/under_construction.dart';

class MechanicMainScreen extends StatefulWidget {
  const MechanicMainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MechanicMainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Option> options = [
    Option('Appointment', Icons.schedule),
    Option('Blog', Icons.book),
    Option('Appoint History', Icons.history),
    Option('AutoParts', Icons.build),
    Option('Parts Order', Icons.list),
    Option('Garage', Icons.location_on),
  ];

  @override
  Widget build(BuildContext context) {
    String selectedMode = "Vehicle Owner";
    final User? user = _auth.currentUser;
    final String userId = user?.uid ?? '';
    return WillPopScope(
        onWillPop: () async {
          // Save current login user here

          // Close the app
          SystemNavigator.pop();
          return false;
        },

        ///
        child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddGarageScreen()),
                );
              },
              icon: Icon(
                Icons.directions_car,
                color: Colors.black,
              ),
              label: Text('Add Garage'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            appBar: AppBar(
              title: Text('AutoKaar'),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UnderConstructionScreen()),
                    );
                  },
                  icon: GestureDetector(
                    onTap: () async {
                      List<String> garageIds =
                          await findGarageIdsForUser(userId);
                      // Define the action to be performed when the chat icon is tapped
                      // For example, navigate to the chat screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MechanicChatScreen(garageIds: garageIds)),
                      );
                    },
                    child: Stack(
                      children: [
                        Icon(Icons.chat),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Text(
                      'AutoKaar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileScreenX(user: user),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('User not found.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Switch To User'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            body: Column(children: [
              SizedBox(
                height: 125,
                width: 500,
                child: GridView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: options.length,
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomMenuScreen()),
                          );
                        }
                        if (index == 0) {
                          String currentUSERTHAT = getCurrentUserUid();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyGaragesScreen()),
                          );
                        }
                        if (index == 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ShowAutoParts(garageId: 'xxxx')),
                          );
                        }
                        if (index == 4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyGaragesScreenPart()),
                          );
                        }
                        if (index == 5) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MechanicMapScreen()),
                          );
                        }
                        if (index == 2) {
                          String currentUSERTHAT = getCurrentUserUid();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SelectGarage(userId: currentUSERTHAT)),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Colors.black, Colors.black],
                            // Specify your desired colors
                            begin: Alignment.topLeft,
                            // Adjust the gradient start point as needed
                            end: Alignment
                                .bottomRight, // Adjust the gradient end point as needed
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 10,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(options[index].icon, size: 30),
                            SizedBox(height: 8),
                            Text(
                              options[index].name,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('mechanicGarage')
                      .where('userID', isEqualTo: userId) // Filter by user ID
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = snapshot.data!.docs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GarageDetailsScreen(
                                  garageId: document['garagenum'],
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
                                // Specify your desired colors
                                begin: Alignment.topLeft,
                                // Adjust the gradient start point as needed
                                end: Alignment
                                    .bottomRight, // Adjust the gradient end point as needed
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
                                vertical: 5, horizontal: 10),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: document['imageUrl'],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      document['imageUrl'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        document['garageName'],
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ); //
                  },
                ),
              ),
            ])));
  }

  String getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      // Handle the case when the user is not logged in
      throw Exception("User is not logged in.");
    }
  }

  Future<List<String>> findGarageIdsForUser(String userId) async {
    List<String> garageIds = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('mechanicGarage')
        .where('userID', isEqualTo: userId)
        .get();

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      String garageId = doc['garagenum'] as String;
      garageIds.add(garageId);
    }

    return garageIds;
  }
}

class Option {
  final String name;
  final IconData icon;

  Option(this.name, this.icon);
}

////

class MyGaragesScreen extends StatelessWidget {
  String getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      // Handle the case when the user is not logged in
      throw Exception("User is not logged in.");
    }
  }

  MyGaragesScreen();

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
                      builder: (context) =>
                          AppointmentListScreen(garageId: garageId),
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

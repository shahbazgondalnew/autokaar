import 'package:autokaar/mechanicMod/addAutoparts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class MechanicService {
  final String id;
  final String serviceName;

  MechanicService({required this.id, required this.serviceName});
}

class Autopart {
  final String name;
  final String garageID;
  final String category;
  final String subcategory;
  final String image;
  final int quantity;
  final int price;
  final int averageLife;
  final bool inStock;

  final List<SuitableCar> suitableCars; // Add this field

  Autopart({
    required this.name,
    required this.garageID,
    required this.category,
    required this.subcategory,
    required this.image,
    required this.quantity,
    required this.inStock,
    required this.averageLife,
    required this.suitableCars,
    required this.price, // Add this field
  });
}

// Add SuitableCar class
class SuitableCar {
  final String companyName;
  final String modelName;

  SuitableCar({required this.companyName, required this.modelName});
}

class ShowAutoParts extends StatefulWidget {
  final String garageId;

  ShowAutoParts({required this.garageId});

  @override
  _ShowAutoPartsState createState() => _ShowAutoPartsState();
}

class _ShowAutoPartsState extends State<ShowAutoParts> {
  List<String> addedServices = [];
  List<MechanicService> services = [];
  List<Autopart> addedAutoparts = [];

  @override
  void initState() {
    super.initState();
    fetchAddedServices();
    fetchAddedAutoparts();
  }

  Future<void> fetchAddedServices() async {
    DocumentSnapshot garageSnapshot = await FirebaseFirestore.instance
        .collection('addedService')
        .doc(widget.garageId)
        .get();

    if (garageSnapshot.exists) {
      Map<String, dynamic>? data =
          garageSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('services')) {
        setState(() {
          addedServices = List<String>.from(data['services'] as List<dynamic>);
        });
        await fetchServices();
      }
    }
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

  Future<void> fetchServices() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('mechanicService').get();
    List<MechanicService> fetchedServices = snapshot.docs.map((doc) {
      return MechanicService(
        id: doc.id,
        serviceName: doc.get('serviceName'),
      );
    }).toList();

    setState(() {
      services = fetchedServices;
    });
  }

// Update fetchAddedAutoparts method
  Future<void> fetchAddedAutoparts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('addedpartsall')
        .orderBy('name')
        .get();

    List<Autopart> fetchedAutoparts =
        await Future.wait(snapshot.docs.map((doc) async {
      // Fetch suitableCars array
      List<dynamic> suitableCarsData = doc.get('suitableCars') ?? [];
      List<SuitableCar> suitableCars = suitableCarsData.map((carData) {
        return SuitableCar(
          companyName: carData['companyName'] ?? '',
          modelName: carData['modelName'] ?? '',
        );
      }).toList();

      return Autopart(
        name: doc.get('name'),
        category: doc.get('category'),
        subcategory: doc.get('subcategory'),
        image: doc.get('image'),
        quantity: doc.get('quantity'),
        inStock: doc.get('inStock') as bool? ?? false,
        suitableCars: suitableCars,
        price: doc.get('price'),
        garageID: doc.get('garageID'), averageLife: doc.get('averageLife'),

        // Pass suitableCars to Autopart
      );
    }));

    setState(() {
      addedAutoparts = fetchedAutoparts.toList();
    });
  }

  String getServiceName(String serviceId) {
    MechanicService? service =
        services.firstWhereOrNull((service) => service.id == serviceId);
    return service?.serviceName ?? '';
  }

  String getAvailabilityText(int quantity, bool inStock) {
    if (inStock && quantity > 0) {
      return 'In Stock';
    } else {
      return 'Out of Stock';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          String currentMechanicUID = getCurrentUserUid();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyGaragesScreen(
                userId: currentMechanicUID,
              ),
            ),
          );
        },
        icon: Icon(
          Icons.directions_car,
          color: Colors.black,
        ),
        label: Text('Add AutoParts'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      appBar: AppBar(
        title: Text('AutoParts'),
      ),
      body: addedAutoparts.isNotEmpty
          ? GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.75,
              ),
              itemCount: addedAutoparts.length,
              itemBuilder: (context, index) {
                Autopart autopart = addedAutoparts[index];
                return Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          autopart.image,
                          fit: BoxFit.cover,
                          width: double
                              .infinity, // Set image width to fill the container
                          height: 150.0, // Set a fixed height for the image
                        ),
                      ),
                      SizedBox(height: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          autopart.name,
                          style: TextStyle(color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${autopart.quantity} available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      // Use Spacer to push the following text to the bottom
                      // Add a gap between image and text
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child: Text(
                          getAvailabilityText(
                              autopart.quantity, autopart.inStock),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Text('No autoparts added'),
            ),
    );
  }
}

////////////
//select garage
class MyGaragesScreen extends StatelessWidget {
  final String userId;

  MyGaragesScreen({required this.userId});

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
              final garageData =
                  garageDocs[index].data() as Map<String, dynamic>;
              final garageName = garageData['garageName'] as String;
              final garageId = garageDocs[index].id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddAutopartScreen(garageId: garageId)),
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

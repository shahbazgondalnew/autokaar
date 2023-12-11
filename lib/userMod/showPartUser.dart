import 'package:autokaar/mechanicMod/addAutoparts.dart';
import 'package:autokaar/mechanicMod/showAutoparts.dart';
import 'package:autokaar/userMod/autopartScreenD.dart';
import 'package:autokaar/userMod/autopart_suggestion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:autokaar/mechanicMod/showAutoparts.dart';

class MechanicService {
  final String id;
  final String serviceName;

  MechanicService({required this.id, required this.serviceName});
}

class ShowAutoPartsUser extends StatefulWidget {
  ShowAutoPartsUser();

  @override
  _ShowAutoPartsUserState createState() => _ShowAutoPartsUserState();
}

class _ShowAutoPartsUserState extends State<ShowAutoPartsUser> {
  List<String> addedServices = [];
  List<MechanicService> services = [];
  List<Autopart> addedAutoparts = [];
  String selectedOption = 'All';

  @override
  void initState() {
    super.initState();
    fetchAddedServices();
    fetchAddedAutoparts();
  }

  Future<void> fetchAddedServices() async {
    DocumentSnapshot garageSnapshot =
        await FirebaseFirestore.instance.collection('addedService').doc().get();

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
      appBar: AppBar(
        title: Text('AutoPartsX'),
      ),
      body: Column(
        children: [
          // DropdownButton for selecting options
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedOption,
              onChanged: (String? newValue) async {
                setState(() {
                  selectedOption = newValue ?? 'All';
                });

                // Fetch autoparts based on the selected option
                if (selectedOption == 'All') {
                  fetchAddedAutoparts(); // Fetch all autoparts
                } else {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    String uid = currentUser.uid;
                    List<Autopart> suggestedAutoparts =
                        await AutoPartSuggestion()
                            .suggestAutoParts(uid, addedAutoparts);

                    setState(() {
                      addedAutoparts = suggestedAutoparts;
                    });
                    print('Current user UID: $uid');
                  } else {
                    print('No user is currently logged in.');
                  }
                }
              },
              items: ['All', 'Suggested'].map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
          // Autoparts GridView
          Expanded(
            child: addedAutoparts.isNotEmpty
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
                      return GestureDetector(
                          onTap: () {
                            // Navigate to the details screen with the autopart ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AutopartDetailsScreen(
                                  autopart: autopart,
                                ),
                              ),
                            );
                          },
                          child: Container(
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
                                    width: double.infinity,
                                    height: 150.0,
                                  ),
                                ),
                                SizedBox(height: 1.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    autopart.name.length > 20
                                        ? autopart.name.substring(0, 20)
                                        : autopart.name,
                                    style: TextStyle(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(height: 1.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    '${autopart.price} RS',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 8.0),
                                  child: Text(
                                    getAvailabilityText(
                                        autopart.quantity, autopart.inStock),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ));
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }
}

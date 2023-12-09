import 'package:autokaar/mechanicMod/addAutoparts.dart';
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
  final String category;
  final String subcategory;
  final String image;
  final int quantity;
  final bool inStock;

  Autopart({
    required this.name,
    required this.category,
    required this.subcategory,
    required this.image,
    required this.quantity,
    required this.inStock,
  });
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
        .collection('addedparts')
        .orderBy('name')
        .get();
    List<Autopart> fetchedAutoparts = snapshot.docs.map((doc) {
      return Autopart(
          name: doc.get('name'),
          category: doc.get('category'),
          subcategory: doc.get('subcategory'),
          image: doc.get('image'),
          quantity: doc.get('quantity'),
          inStock: true
          //inStock: doc.get('inStock') as bool? ?? false,
          );
    }).toList();

    setState(() {
      addedAutoparts = fetchedAutoparts;
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAutopartScreen(),
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
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
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
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                autopart.image,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              autopart.name,
                              style: TextStyle(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${autopart.quantity} available',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (addedAutoparts[index].image.isEmpty)
                      CircularProgressIndicator(),
                    Positioned(
                      bottom: 8.0,
                      left: 8.0,
                      child: Text(
                        getAvailabilityText(
                            autopart.quantity, autopart.inStock),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            )
          : Center(
              child: Text('No autoparts added'),
            ),
    );
  }
}

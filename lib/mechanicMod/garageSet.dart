import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:autokaar/mechanicMod/addItem.dart';
import 'package:autokaar/mechanicMod/setWorkingHour.dart';

class MechanicService {
  final String id;
  final String serviceName;

  MechanicService({required this.id, required this.serviceName});
}

class GarageDetailsScreen extends StatefulWidget {
  final String garageId;

  GarageDetailsScreen({required this.garageId});

  @override
  _GarageDetailsScreenState createState() => _GarageDetailsScreenState();
}

class _GarageDetailsScreenState extends State<GarageDetailsScreen> {
  List<String> addedServices = [];
  List<MechanicService> services = [];

  @override
  void initState() {
    super.initState();
    fetchAddedServices();
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
        Map<String, dynamic> serviceData =
        Map<String, dynamic>.from(data['services'] as Map);

        List<String> serviceIds = serviceData.keys.toList();

        setState(() {
          addedServices = serviceIds;
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

  String getServiceName(String serviceId) {
    MechanicService? service =
    services.firstWhereOrNull((service) => service.id == serviceId);
    return service?.serviceName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SetWorkingHoursScreen(
                    garageId: widget.garageId,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.access_time,
              color: Colors.black,
            ),
            label: Text('Set Working Hour'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMechanicServiceScreen(
                    garageId: widget.garageId,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.directions_car,
              color: Colors.black,
            ),
            label: Text('Add Service or Item'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text('Garage Details'),
      ),
      body: addedServices.isNotEmpty
          ? ListView.builder(
        itemCount: addedServices.length + 1, // +1 for the heading
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
              child: ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                title: Text(
                  'Services',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          } else {
            String serviceId = addedServices[index - 1];
            String serviceName = getServiceName(serviceId);
            return Container(
              margin:
              EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
              child: ListTile(
                title: Text(
                  serviceName,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
      )
          : Center(
        child: Text('No service added'),
      ),
    );
  }
}

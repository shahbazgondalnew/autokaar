import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MechanicService {
  final String id;
  final String serviceName;
  int? inputValue;
  int? performServiceTime;

  MechanicService({
    required this.id,
    required this.serviceName,
    required this.inputValue,
    required this.performServiceTime,
  });
}

class AddMechanicServiceScreen extends StatefulWidget {
  final String garageId;

  AddMechanicServiceScreen({required this.garageId});

  @override
  _AddMechanicServiceScreenState createState() =>
      _AddMechanicServiceScreenState();
}

class _AddMechanicServiceScreenState extends State<AddMechanicServiceScreen> {
  List<MechanicService> allServices = [];
  List<String> selectedServices = [];
  Map<String, int> servicePrices = {};
  Map<String, int?> serviceTimes = {};
  Map<String, TextEditingController> priceControllers = {};

  @override
  void initState() {
    super.initState();
    fetchAllServices();
    fetchSelectedServices();
  }

  Future<void> fetchAllServices() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('mechanicService').get();
    List<MechanicService> services = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      int? inputValue = data['inputValue'] as int?;
      int? performServiceTime = data['performServiceTime'] as int?;

      return MechanicService(
        id: doc.id,
        serviceName: data['serviceName'],
        inputValue: inputValue,
        performServiceTime: performServiceTime,
      );
    }).toList();

    setState(() {
      allServices = services;
    });
  }

  Future<void> fetchSelectedServices() async {
    try {
      DocumentSnapshot garageSnapshot = await FirebaseFirestore.instance
          .collection('addedService')
          .doc(widget.garageId)
          .get();

      if (garageSnapshot.exists) {
        Map<String, dynamic>? data =
            garageSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('services')) {
          Map<String, dynamic> selectedServicesData =
              Map<String, dynamic>.from(data['services'] as Map);
          setState(() {
            selectedServices = selectedServicesData.keys.toList();
            servicePrices = selectedServicesData.map(
                (key, value) => MapEntry(key, value['servicePrice'] as int));
            serviceTimes = selectedServicesData //price for a service added
                .map((key, value) => MapEntry(key, value['timeTaken'] as int?));
          });
        }
      }
    } catch (error) {
      // Handle error here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Autokaar'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.0),
            Text(
              'Select Services:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: allServices.length,
                itemBuilder: (context, index) {
                  MechanicService service = allServices[index];
                  bool isSelected = selectedServices.contains(service.id);
                  int inputValue = servicePrices[service.id] ?? 0;
                  int? serviceTime = serviceTimes[service.id];

                  return Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedServices.add(service.id);
                            } else {
                              selectedServices.remove(service.id);
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.serviceName),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Time to Complete (minutes)',
                              ),
                              initialValue: serviceTime?.toString() ?? '',
                              onChanged: (value) {
                                setState(() {
                                  serviceTimes[service.id] =
                                      int.tryParse(value);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: serviceTime?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Price(RS)",
                          ),
                          onChanged: (value) {
                            setState(() {
                              int parsedValue = int.tryParse(value) ?? 0;
                              if (parsedValue > 1) {
                                servicePrices[service.id] = parsedValue;
                              } else {
                                // Show a SnackBar with an error message.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Value must be greater than 1'),
                                  ),
                                );
                              }
                            });
                          },
                          controller: priceControllers[service.id],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                saveSelectedServices();
              },
              child: Text('Save Services'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveSelectedServices() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Map<String, dynamic> servicesData = {};

      for (String serviceId in selectedServices) {
        int price = servicePrices[serviceId] ?? 0;
        int? timeTaken = serviceTimes[serviceId];

        Map<String, dynamic> serviceEntry = {
          'servicePrice': price,
        };

        if (timeTaken != null) {
          serviceEntry['timeTaken'] = timeTaken;
        }

        servicesData[serviceId] = serviceEntry;
      }

      await firestore
          .collection('addedService')
          .doc(widget.garageId)
          .set({'services': servicesData}, SetOptions(merge: true));

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving services: $error'),
        ),
      );
    }
  }
}

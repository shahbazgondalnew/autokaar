import 'package:autokaar/mechanicMod/addAutoparts.dart';
import 'package:autokaar/mechanicMod/showAutoparts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:autokaar/userMod/car_model.dart';

class SuitableCarScreen extends StatefulWidget {
  @override
  _SuitableCarScreenState createState() => _SuitableCarScreenState();
}

class _SuitableCarScreenState extends State<SuitableCarScreen> {
  late List<CarModel> carModels = [];
  String selectedModelLOcal = "";
  String selectedCompanyLocal = "";
  String? selectedCompany;
  String? selectedModel;
  List<SuitableCar> addedCars = []; // List to store added cars

  @override
  void initState() {
    super.initState();
    fetchCarModels();
  }

  List<String> getModelsForCompany(String company) {
    return carModels
        .where((model) => model.companyName == company)
        .map((model) => model.modelName)
        .toList();
  }

  List<String> getDistinctCompanies() {
    return carModels.map((model) => model.companyName).toSet().toList();
  }

  Future<void> fetchCarModels() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('carsModels').get();
    List<CarModel> models = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return CarModel(
        id: doc.id,
        companyName: data['companyName'],
        modelName: data['modelName'],
      );
    }).toList();

    setState(() {
      carModels = models;
    });
  }

  Widget build(BuildContext context) {
    List<String> companies = getDistinctCompanies();
    List<String> models =
        selectedCompany != null ? getModelsForCompany(selectedCompany!) : [];
    return Scaffold(
      appBar: AppBar(
        title: Text('Suitable Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your car selection UI goes here
            // Dropdowns, input fields, etc.

            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedCompany,
              hint: Text('Select Company'),
              onChanged: (value) {
                setState(() {
                  selectedCompany = value;
                  selectedCompanyLocal = selectedCompany!;
                  selectedModel =
                      null; // Reset selected model when company changes
                });
              },
              items: companies.map((company) {
                return DropdownMenuItem<String>(
                  value: company,
                  child: Text(company),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedModel,
              hint: Text('Select Model'),
              onChanged: (value) {
                setState(() {
                  selectedModel = value;
                  selectedModelLOcal = value.toString();
                });
              },
              items: models.map((model) {
                return DropdownMenuItem<String>(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
            ),

            ElevatedButton(
              onPressed: () {
                // Add the selected car to the list
                if (selectedCompany != null && selectedModel != null) {
                  setState(() {
                    addedCars.add(
                      SuitableCar(
                        companyName: selectedCompany!,
                        modelName: selectedModel!,
                      ),
                    );
                    selectedCompany = null;
                    selectedModel = null;
                  });
                }
              },
              child: Text('Add Car'),
            ),

            SizedBox(height: 16.0),

            // Display added cars
            Text('Added Cars:'),
            for (SuitableCar car in addedCars)
              Text('${car.companyName} - ${car.modelName}'),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, addedCars);
              // Implement logic to save the cars
            },
            child: Text('Save'),
          ),
        ),
      ),
    );
  }
}

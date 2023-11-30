import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'car_model.dart';

class AddCarScreen extends StatefulWidget {
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  String? selectedCompany;

  List<String> companies = [
    'Company A',
    'Company B',
    'Company C',
    // Add more company names as needed
  ];

  void _addCarModel(String companyName, String modelName) {
    String carModelID = const Uuid().v1();
    CarModel carModel = CarModel(
      companyName: companyName,
      modelName: modelName,
      id: carModelID,
    );

    FirebaseFirestore.instance.collection('carModels').add({
      'companyName': carModel.companyName,
      'modelName': carModel.modelName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Car'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedCompany,
              hint: Text('Select Company'),
              onChanged: (value) {
                setState(() {
                  selectedCompany = value;
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
            TextField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: 'Model',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (selectedCompany != null) {
                  String companyName = selectedCompany!;
                  String modelName = _modelController.text;

                  _addCarModel(companyName, modelName);

                  _modelController.clear();
                  setState(() {
                    selectedCompany = null;
                  });
                } else {
                  print('Please select a company');
                }
              },
              child: Text('Add Car'),
            ),
          ],
        ),
      ),
    );
  }
}

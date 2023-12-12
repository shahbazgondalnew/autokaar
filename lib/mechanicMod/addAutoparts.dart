import 'dart:io';

import 'package:autokaar/mechanicMod/showAutoparts.dart';
import 'package:autokaar/mechanicMod/suitableCarForPart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddAutopartScreen extends StatefulWidget {
  final String garageId;
  AddAutopartScreen({super.key, required this.garageId});

  @override
  _AddAutopartScreenState createState() => _AddAutopartScreenState();
}

class _AddAutopartScreenState extends State<AddAutopartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  List<Autopart> _autopartSuggestions = [];
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _averageLifeController = TextEditingController();

  List<String> _categories = [];
  Map<String, List<String>> _subcategories = {};
  String? _selectedCategory;
  String? _selectedSubcategory;
  bool _inStock = false;
  List<SuitableCar> addedCars = [];

  ///
  ///

  @override
  void initState() {
    super.initState();
    fetchDistinctCategories();
  }

  Future<void> fetchDistinctCategories() async {
    _categories = await getDistinctCategories();
    setState(() {});
  }

  Future<List<String>> getDistinctCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('partcate').get();
    Set<String> categories = Set<String>();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      String category = doc['cat'] as String;
      categories.add(category);
    }
    return categories.toList();
  }

  Future<void> fetchDistinctSubcategories(String category) async {
    _subcategories[category] =
        await getDistinctSubcategoriesForCategory(category);
    print("sub");
    print(_subcategories);
    print("sub");
    setState(() {});
  }

  Future<List<String>> getDistinctSubcategoriesForCategory(
      String category) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('partcate')
        .where('cat', isEqualTo: category)
        .get();
    Set<String> subcategories = Set<String>();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      String subcategory = doc['subcat'] as String;
      subcategories.add(subcategory);
    }
    print(category);
    print(subcategories);
    return subcategories.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Autopart'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedSubcategory = null;
                      print(value);
                      if (value != null) {
                        fetchDistinctSubcategories(value);
                      }
                    });
                  },
                  hint: Text('Select Category'),
                  isExpanded: true,
                ),
                DropdownButton<String>(
                  value: _selectedSubcategory,
                  items: _selectedCategory != null &&
                          _subcategories[_selectedCategory] != null
                      ? _subcategories[_selectedCategory]!.map((subcategory) {
                          return DropdownMenuItem<String>(
                            value: subcategory,
                            child: Text(subcategory),
                          );
                        }).toList()
                      : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubcategory = value;
                    });
                  },
                  hint: Text('Select Subcategory'),
                  isExpanded: true,
                ),
                SizedBox(height: 16.0),
                _buildImagePicker(),
                SizedBox(height: 16.0),
                CheckboxListTile(
                  title: Text('In Stock'),
                  value: _inStock,
                  onChanged: (value) {
                    setState(() {
                      _inStock = value!;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller:
                      _priceController, // Add a TextEditingController for the price
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price';
                    }
                    final double price = double.tryParse(value) ?? 0.0;
                    if (price < 0) {
                      return 'Price cannot be negative';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller:
                      _averageLifeController, // Add a TextEditingController for the average life
                  decoration:
                      InputDecoration(labelText: 'Average Life (in Kilometer)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the average life';
                    }
                    final double averageLife = double.tryParse(value) ?? 0.0;
                    if (averageLife <= 0) {
                      return 'Average Life must be greater than 0';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to SuitableCarScreen
                    final List<SuitableCar>? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuitableCarScreen(),
                      ),
                    );

                    // Handle the result (added cars)
                    if (result != null) {
                      setState(() {
                        // Update your state or perform any logic with the added cars
                        addedCars.addAll(result);
                      });
                    }
                  },
                  child: Text('Add Car'),
                ),

// Display the list of added cars below the button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: addedCars
                      .map((car) => Text('${car.companyName} ${car.modelName}'))
                      .toList(),
                ),

                SizedBox(height: 16),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (addedCars.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('kindly add suitable car')),
                      );
                    } else {
                      await _submitFormTwo(widget.garageId, addedCars);
                    }
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Image'),
        SizedBox(height: 8.0),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: _image == null
                ? Icon(Icons.camera_alt, size: 48.0)
                : Image.file(_image!, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _submitFormTwo(
      String garageID, List<SuitableCar> addedCars) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text;
    final category = _selectedCategory!;
    final subcategory = _selectedSubcategory!;
    final quantity = int.parse(_quantityController.text);
    final priceOfpart = int.parse(_priceController.text);
    final averageLife = int.parse(_averageLifeController.text);

    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize Firebase

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('allpartImages/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final uploadSnapshot = await uploadTask.whenComplete(() => null);
      final downloadURL = await uploadSnapshot.ref.getDownloadURL();

      // Create autopart object
      final autopart = {
        'name': name,
        'category': category,
        'subcategory': subcategory,
        'image': downloadURL,
        'quantity': quantity,
        'inStock': _inStock,
        'price': priceOfpart,
        'garageID': garageID,
        'averageLife': averageLife
      };

      // Add autopart to Firestore
      DocumentReference autopartReference = await FirebaseFirestore.instance
          .collection('addedpartsall')
          .add(autopart);

      // Add suitable cars to the autopart document
      await addSuitableCarsToAutopart(autopartReference.id, addedCars);

      setState(() {
        _isLoading = false;
      });

      // Clear form fields

      // Show success message
      await _submitForm(widget.garageId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Autopart added successfully')),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add autopart')),
      );
    }
  }

  Future<void> addSuitableCarsToAutopart(
      String autopartId, List<SuitableCar> addedCars) async {
    // Create a list of maps from the SuitableCar objects
    List<Map<String, dynamic>> carsList = addedCars
        .map((car) => {
              'companyName': car.companyName,
              'modelName': car.modelName,
            })
        .toList();

    // Add the list of cars to the autopart document
    await FirebaseFirestore.instance
        .collection('addedpartsall')
        .doc(autopartId)
        .update({'suitableCars': FieldValue.arrayUnion(carsList)});
  }

  Future<void> _submitForm(String garageID) async {
    print("top");
    if (!_formKey.currentState!.validate()) {
      return;
    }
    print("top2");

    final name = _nameController.text;
    final category = _selectedCategory!;
    final subcategory = _selectedSubcategory!;
    final quantity = int.parse(_quantityController.text);
    final priceOfpart = int.parse(_priceController.text);
    final averageLife = int.parse(_averageLifeController.text);

    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize Firebase

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('partImages/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final uploadSnapshot = await uploadTask.whenComplete(() => null);
      final downloadURL = await uploadSnapshot.ref.getDownloadURL();

      // Create autopart object
      final autopart = {
        'name': name,
        'category': category,
        'subcategory': subcategory,
        'image': downloadURL,
        'quantity': quantity,
        'inStock': _inStock,
        'price': priceOfpart,
        'garageID': garageID,
        'averageLife': averageLife
      };

      // Add autopart to Firestore
      await FirebaseFirestore.instance.collection('addedparts').add(autopart);

      setState(() {
        _isLoading = false;
      });

      // Clear form fields
      _nameController.clear();
      _quantityController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Autopart added successfully')),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add autopart')),
      );
    }
  }
}

import 'dart:io';
import 'package:autokaar/userMod/postClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'addnewcarIncomp.dart';
import 'car_model.dart';
import 'package:autokaar/commonMod/logjson.dart';

class SelectCarScreen extends StatefulWidget {
  @override
  _SelectCarScreenState createState() => _SelectCarScreenState();
}

class _SelectCarScreenState extends State<SelectCarScreen> {
  late List<CarModel> carModels = [];
  String? selectedCompany;
  String? selectedModel;
  late Future<String> uploadd;
  late String imageUrln;
  final meterController = TextEditingController();
  final nameController = TextEditingController();
  String selectedModelLOcal = "";
  String selectedCompanyLocal = "";

  File? _imageFileshow;
  @override
  void initState() {
    super.initState();
    fetchCarModels();
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

  List<String> getDistinctCompanies() {
    return carModels.map((model) => model.companyName).toSet().toList();
  }

  List<String> getModelsForCompany(String company) {
    return carModels
        .where((model) => model.companyName == company)
        .map((model) => model.modelName)
        .toList();
  }

  Future<void> _pickImageshow(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFileshow = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.6;
    List<String> companies = getDistinctCompanies();
    List<String> models =
    selectedCompany != null ? getModelsForCompany(selectedCompany!) : [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Car'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter Name',
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {},
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: meterController,
                decoration: InputDecoration(
                  hintText: 'Current Meter Reading',
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {},
              ),
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
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Photo Library'),
                              onTap: () {
                                _pickImageshow(ImageSource.gallery);
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_camera),
                              title: Text('Camera'),
                              onTap: () {
                                _pickImageshow(ImageSource.camera);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300],
                    image: _imageFileshow != null
                        ? DecorationImage(
                      image: FileImage(_imageFileshow!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _imageFileshow == null
                      ? Icon(
                    Icons.add_a_photo,
                    size: 70,
                    //50
                    color: Colors.grey[800],
                  )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Time and Total Price

            SizedBox(height: 16),

            // Confirm Booking Button
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Name cannot be empty'),
                    ),
                  );
                } else if (meterController.text.isEmpty ||
                    double.tryParse(meterController.text)! <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Current meter reading must be a positive number'),
                    ),
                  );
                } else if (selectedCompany == null || selectedModel == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a company and model'),
                    ),
                  );
                } else if (_imageFileshow == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select an image'),
                    ),
                  );
                } else {
                  // All checks pass, proceed with upload.
                  uploadcarImage();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 5,
                minimumSize: Size(double.infinity, 0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text(
                    'Add Car',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }





Future<void> uploadcarImage() async {
    final firebaseStorage = FirebaseStorage.instance;
    if (_imageFileshow != null) {
      String postname = const Uuid().v1();
      var snapshot = await firebaseStorage
          .ref()
          .child('carphotos/$postname')
          .putFile(_imageFileshow!);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      FirebaseAuth auth = FirebaseAuth.instance;
      String cuid = auth.currentUser!.uid.toString();
      imageUrln = downloadUrl;
      uploadPost(cuid, imageUrln);
    }
  }

  Future<String> uploadPost(String uid, String imageUrl) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      // String photoUrl =
      //   await StorageMethods().uploadImageToStorage('posts', file, true);
      String carId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
          carName: nameController.text.toString(),
          uid: uid,
          company: selectedCompanyLocal.toString(),
          urlS: imageUrl,
          region: "PaKistan",
          timestamp: Timestamp.now(),
          currentMeter: meterController.text.toString(),
          carModelname: selectedModelLOcal,
          carID: carId);
      FirebaseFirestore.instance
          .collection('userCar')
          .doc(carId)
          .set(post.toJson());
      res = "success";
      uploadLog(meterController.text.toString(), carId);
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadLog(String meterReading, String carIDM) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      // String photoUrl =
      //   await StorageMethods().uploadImageToStorage('posts', file, true);
      //String carId = const Uuid().v1(); // creates unique id based on time
      carLog logOfCar = carLog(
          frontright: Timestamp.now(),
          frontleft: Timestamp.now(),
          backright: Timestamp.now(),
          backleft: Timestamp.now(),
          service: Timestamp.now(),
          serviceRead: meterReading,
          frontrightRead: meterReading,
          frontleftRead: meterReading,
          backrightRead: meterReading,
          backleftRead: meterReading,
          backleftReadTitle: 'Back Left Tyre',
          backrightReadTitle: 'Back Right Tyre',
          frontleftReadTitle: 'Front Left Tyre',
          frontrightReadTitle: 'Front Right',
          serviceTitle: 'Service');
      FirebaseFirestore.instance
          .collection('carlog')
          .doc(carIDM)
          .set(logOfCar.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}

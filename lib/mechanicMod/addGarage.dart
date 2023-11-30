  import 'dart:io';

  import 'package:autokaar/mechanicMod/locationGarage.dart';
  import 'package:autokaar/userMod/postClass.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/services.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:uuid/uuid.dart';
  import 'package:autokaar/userMod/addnewcarIncomp.dart';
  import 'package:autokaar/userMod/car_model.dart';
  import 'package:autokaar/mechanicMod/locationGarage.dart';
  import 'package:autokaar/mechanicMod/garageClass.dart';
  import 'package:autokaar/commonMod/logjson.dart';

  class AddGarageScreen extends StatefulWidget {
    @override
    _AddGarageScreenState createState() => _AddGarageScreenState();
  }

  class _AddGarageScreenState extends State<AddGarageScreen> {
    late List<CarModel> carModels = [];
    String? selectedCompany;
    String? selectedModel;
    late Future<String> uploadFuture;
    late String imageUrl;
    final meterController = TextEditingController();
    final nameController = TextEditingController();
    String selectedModelLocal = "";
    String selectedCompanyLocal = "";
    LatLng? selectedLocation;

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

    Future<void> _pickImageShow(ImageSource source) async {
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
                  if (validateInputs() && validateLocation()) {
                    // All inputs are valid, proceed to upload garage image and data
                    uploadgarageImage();
                    // Successfully added garage, navigate back to the previous screen
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Change the background color to green
                  onPrimary: Colors.white, // Button text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  elevation: 5, // Button elevation
                  minimumSize: Size(double.infinity, 0), // Full width
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text(
                      'Add Garage',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Add Garage'),
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
                                  _pickImageShow(ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_camera),
                                title: Text('Camera'),
                                onTap: () {
                                  _pickImageShow(ImageSource.camera);
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
                            color: Colors.grey[800],
                          )
                        : null,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Open the map picker or map screen
                    final LatLng? location = await pickLocationFromMap();
                    print(location.toString());
                    if (location != null) {
                      setState(() {
                        selectedLocation = location;
                      });
                    }
                  },
                  child: Text('Select Location'),
                ),

              ],
            ),
          ),
        ),
      );
    }
    bool validateInputs() {
      if (nameController.text.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a name for the garage.'),
          ),
        );
        return false;
      } else if (_imageFileshow == null) {
        // Display an error message for missing garage image
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a garage image.'),
          ),
        );
        return false;
      }
      return true;
    }


    bool validateLocation() {
      if (selectedLocation == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a location for the garage.'),
          ),
        );
        return false;
      }
      return true; // Location validation passed
    }

    Future<void> uploadgarageImage() async {
      final firebaseStorage = FirebaseStorage.instance;
      if (_imageFileshow != null) {
        String imageName = const Uuid().v1();
        var snapshot = await firebaseStorage
            .ref()
            .child('garagePhoto/$imageName')
            .putFile(_imageFileshow!);
        var downloadUrl = await snapshot.ref.getDownloadURL();

        FirebaseAuth auth = FirebaseAuth.instance;
        String userId = auth.currentUser!.uid.toString();
        imageUrl = downloadUrl;
        uploadPost(userId, imageUrl);
      }
    }

    Future<String> uploadPost(String userId, String imageUrl) async {
      String res = "Some error occurred";
      try {
        String garageId = const Uuid().v1();
        double latitudevar = selectedLocation!.latitude;
        double longitudevar = selectedLocation!.longitude;
        Garage newGarageData = Garage(
            garageName: nameController.text.toString(),
            imageUrl: imageUrl,
            googleLocation: {
              "latitude": latitudevar,
              "longitude": longitudevar,
            },
            userID: userId,
            statusOfGarage: "Pending",
            garagenum: garageId);

        FirebaseFirestore.instance
            .collection('mechanicGarage')
            .doc(garageId)
            .set(newGarageData.toJson())
            .then((_) {
          res = "success";
        }).catchError((error) {
          res = "Error uploading garage data: $error";
        });
      } catch (err) {
        res = err.toString();
      }
      return res;
    }

    Future<Position?> getCurrentLocation() async {
      bool serviceEnabled;
      LocationPermission permission;


      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }


      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error(
              'Location permissions are denied (actual value: $permission).');
        }
      }

      // Retrieve the current position
      return await Geolocator.getCurrentPosition();
    }

    Future<LatLng?> pickLocationFromMap() async {
      final Position? currentLocation = await getCurrentLocation();
      if (currentLocation != null) {
        // Use the current location as the initial position on the map
        final initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 16.0,
        );


        final selectedCameraPosition = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              initialCameraPosition: initialCameraPosition,
            ),
          ),
        );

        if (selectedCameraPosition != null) {
          return LatLng(
            selectedCameraPosition.target.latitude,
            selectedCameraPosition.target.longitude,
          );
        }
      }

      return null;
    }
  }

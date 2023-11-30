
import 'package:autokaar/userMod/showFreeSlot.dart';
import 'package:autokaar/userMod/showNearbyMechanic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../commonMod/notificationClass.dart';


class BookingScreen extends StatefulWidget {
  final String garageId;

  const BookingScreen({required this.garageId});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String selectedCarId=''; // To store the selected car's ID
  GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key for validation

  Map<String, dynamic>? selectedCar;
  Map<String, dynamic> workingHours = {};
  DateTime selectedDate = DateTime.now();




  List<Service> services = []; // List to hold available services
  Map<String, bool> selectedServices = {}; // Map to hold selected services
  var selectedStartTime;
  bool validTime=false;
  @override
  void initState() {
    super.initState();
    determineWorkingHours(selectedDate);
    fetchMechanicServices();
  }

  void determineWorkingHours(DateTime date) {
    int weekday = date.weekday - 1;

    FirebaseFirestore.instance
        .collection('garages')
        .doc(widget.garageId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> garageData =
        documentSnapshot.data() as Map<String, dynamic>;

        if (garageData.containsKey('workingHours')) {
          List<dynamic> workingHoursList =
          garageData['workingHours']['days'];

          if (weekday >= 0 && weekday < workingHoursList.length) {
            Map<String, dynamic> workingHoursMap =
            workingHoursList[weekday] as Map<String, dynamic>;

            setState(() {
              workingHours = workingHoursMap;
            });
          } else {
            setState(() {
              workingHours = {}; // Clear working hours if not available for the selected weekday
            });
            print('Working hours not available for the selected weekday.');
          }
        } else {
          setState(() {
            workingHours = {}; // Clear working hours if not available
          });
          print('Working hours data not available.');
        }
      }
    }).catchError((error) {
      setState(() {
        workingHours = {}; // Clear working hours in case of error
      });
      print('Error fetching working hours: $error');
    });
  }

  Future<void> fetchMechanicServices() async {
    try {
      DocumentSnapshot addedServiceSnapshot = await FirebaseFirestore.instance
          .collection('addedService')
          .doc(widget.garageId)
          .get();

      if (addedServiceSnapshot.exists) {
        Map<String, dynamic>? addedServiceData =
        addedServiceSnapshot.data() as Map<String, dynamic>?;

        if (addedServiceData != null && addedServiceData.containsKey('services')) {
          Map<String, dynamic> serviceData =
          Map<String, dynamic>.from(addedServiceData['services'] as Map);

          List<Service> fetchedServices = [];

          for (String serviceId in serviceData.keys) {
            int price = serviceData[serviceId]['servicePrice'] ?? 0;
            int timeTaken = serviceData[serviceId]['timeTaken'] ?? 0;

            // Fetch the service name from the 'mechanicService' collection
            DocumentSnapshot serviceSnapshot = await FirebaseFirestore.instance
                .collection('mechanicService')
                .doc(serviceId)
                .get();

            String serviceName = '';
            if (serviceSnapshot.exists) {
              serviceName = serviceSnapshot.get('serviceName');
            }

            fetchedServices.add(
              Service(
                id: serviceId,
                serviceName: serviceName,
                price: price.toDouble(),
                performServiceTime: timeTaken,
              ),
            );
          }

          setState(() {
            services = fetchedServices;
          });
        }
      }
    } catch (error) {
      print('Error fetching mechanic services: $error');
    }
  }



  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        determineWorkingHours(selectedDate);
      });



    }
  }


  @override
  Widget build(BuildContext context) {
    double totalServicePrice = 0;
    int totalServiceTime = 0;

    selectedServices.forEach((serviceId, isSelected) {
      if (isSelected) {
        Service selectedService =
        services.firstWhere((service) => service.id == serviceId);
        totalServicePrice += selectedService.price;
        totalServiceTime += selectedService.performServiceTime;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Garage'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Date Button
            ElevatedButton.icon(
              onPressed: () => _selectDate(context),
              icon: Icon(Icons.calendar_today),
              label: Text(
                'Select Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: TextStyle(fontSize: 16.0),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black, // Button background color
                onPrimary: Colors.white, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                elevation: 5, // Button elevation
              ),
            ),
            SizedBox(height: 16),
            // Working Hours
            Container(
              width: 300,
              padding: EdgeInsets.all(16),
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
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Working Hours',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Show working hours in a single line
                  Text(
                    'Start: ${workingHours['startHour'] ?? ''}:${workingHours['startMinute'] ?? ''} '
                        '- End: ${workingHours['endHour'] ?? ''}:${workingHours['endMinute'] ?? ''}',
                    style: TextStyle(color: Colors.white),
                  ),
                  // Show if garage is open or closed
                  Text(
                    'Status: ${workingHours['closed'] == true ? 'Closed' : 'Open'}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            // Available Services
            Text(
              'Available Services:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: services.length,
              itemBuilder: (context, index) {
                Service service = services[index];
                bool isSelected = selectedServices.containsKey(service.id)
                    ? selectedServices[service.id]!
                    : false;

                return Column(
                  children: [
                    ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            selectedServices[service.id] = value ?? false;
                          });
                        },
                      ),
                      title: Text(service.serviceName),
                      subtitle: Text(
                          'Price: ${service.price}\nTime Taken: ${service.performServiceTime} mins'),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
            // Select Time Slot Button
            ElevatedButton(
              onPressed: () async {
                print("before");
                selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0);
                print(selectedDate);
                List<Map<String, String>> bookedSlotsData = await fetchBookedSlots(widget.garageId, selectedDate);
                print("after oneX");
                print(workingHours);
                print("other screen");

               final selectedConfirmSlot= await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectSlotScreen(  workingHours: workingHours, bookedSlots: bookedSlotsData, slotDurationInMinutes: totalServiceTime,

                    ),
                  ),
                );// Add this line to pop the current screen.
                if (selectedConfirmSlot != null) {
                  final startTimeString = selectedConfirmSlot.split(' - ')[0]; // Extract the starting time from the selected slot
                  final hour = int.parse(startTimeString.split(':')[0]);
                  final minute = int.parse(startTimeString.split(':')[1]);
                  selectedStartTime = TimeOfDay(hour: hour, minute: minute); // Convert to TimeOfDay
                  print('Selected timeXX: $selectedStartTime');
                  // Now, you have the selected time as a TimeOfDay.
                } else {
                  // Show a SnackBar with the error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No TimeSlot is Selected'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }


                print(selectedConfirmSlot);
              },




              style: ElevatedButton.styleFrom(
                primary: Colors.black, // Button background color
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
                  Icon(Icons.access_time),
                  SizedBox(width: 8),
                  Text(
                    "Booking Slotss",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Divider(),



            ElevatedButton(
              onPressed: () => selectCar(),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
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
                  Icon(Icons.car_rental),
                  SizedBox(width: 8),
                  Text(
                    "Select Car",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Time and Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Time: $totalServiceTime mins',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Price: $totalServicePrice',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Confirm Booking Button
            ElevatedButton(
              onPressed: () {
                print("XXXXXX");
                print(selectedCarId);
                print(selectedStartTime);
                print(totalServiceTime);
                print("XXXXXX");

                if (selectedCarId != null && selectedCarId.isNotEmpty && totalServiceTime != 0 && selectedStartTime != null) {

                  // Check that selectedCarId is not null, totalServiceTime is not zero, and selectedTime is not null
                  uploadToMechanicDailyTimeline(
                    garageId: widget.garageId,
                    date: selectedDate,
                    startTime: selectedStartTime,
                    endTime: addMinutesToTime(selectedStartTime, totalServiceTime),
                    services: selectedServices.keys.toList(),
                    context: context,
                    carId: selectedCarId,
                  );

                } else {
                  // Handle the case where any of the required fields is empty or invalid
                  String errorMessage = '';
                  if (selectedCarId == null) {
                    errorMessage = 'Car ID is required';
                  } else if (totalServiceTime == 0) {
                    errorMessage = 'Total service time cannot be zero';
                  } else if (selectedStartTime == null) {
                    errorMessage = 'Time is not selected';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
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
                    'Confirm Booking',
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
  TimeOfDay addMinutesToTime(TimeOfDay time, int minutesToAdd) {
    int totalMinutes = time.hour * 60 + time.minute + minutesToAdd;
    int newHour = totalMinutes ~/ 60;
    int newMinute = totalMinutes % 60;

    if (newHour >= 24) {
      newHour %= 24; // Wrap around if needed
    }

    return TimeOfDay(hour: newHour, minute: newMinute);
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

  TimeOfDay parseTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<List<Map<String, String>>> fetchBookedSlots(String garageId, DateTime date) async {
    List<Map<String, String>> bookedSlots = [];

    try {
      final DateTime startOfDay = date;
      final DateTime endOfDay = date.add(Duration(days: 1));

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Bookedappointments')
          .where('garageId', isEqualTo: garageId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        final String startTime = doc['startTime'];
        final String endTime = doc['endTime'];

        Map<String, String> booking = {
          'startTime': startTime,
          'endTime': endTime,
        };

        bookedSlots.add(booking);
      }

      // Debug print statement
      print('Booked slots: $bookedSlots');
    } catch (error) {
      print('Error fetching booked slots: $error');
    }
    print(bookedSlots);

    return bookedSlots;
  }


  Future<void> selectCar() async {
    try {
      String userUid = getCurrentUserUid();
      print('User UID: $userUid');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userCar')
          .where('uid', isEqualTo: userUid)
          .get();

      List<Map<String, dynamic>> cars =
      querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print('Number of cars: ${cars.length}');

      Map<String, dynamic>? selectedCarResult = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CarSelectionScreen(cars: cars)),
      );

      if (selectedCarResult != null && selectedCarResult.containsKey('carID')) {
        setState(() {
          selectedCarId = selectedCarResult['carID'];
          selectedCar = selectedCarResult;
          print(selectedCar);
        });
      } else {
        print('Selected car is null or missing "carID" key.');
      }
    } catch (error) {
      print('Error fetching user cars: $error');
    }
  }

  Future<void> updateTimeline(Map<String, dynamic> workingHoursForDay) async {
    try {
      // Calculate the total time taken by booked services
      int totalTimeTaken = 0;
      for (var serviceId in selectedServices.keys) {
        int timeTaken = services.firstWhere((service) => service.id == serviceId).performServiceTime;
        totalTimeTaken += timeTaken;
      }

      // Retrieve the working hours for the selected day
      if (workingHoursForDay.containsKey('startHour') &&
          workingHoursForDay.containsKey('startMinute') &&
          workingHoursForDay.containsKey('endHour') &&
          workingHoursForDay.containsKey('endMinute')) {
        int startHour = workingHoursForDay['startHour'];
        int startMinute = workingHoursForDay['startMinute'];
        int endHour = workingHoursForDay['endHour'];
        int endMinute = workingHoursForDay['endMinute'];

        // Calculate the available time for the day
        int availableTime = endHour * 60 + endMinute - (startHour * 60 + startMinute);

        if (availableTime >= totalTimeTaken) {
          TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: startHour, minute: startMinute),
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
          );

          if (selectedTime != null) {
            int selectedHour = selectedTime.hour;
            int selectedMinute = selectedTime.minute;

            int selectedTotalMinutes = selectedHour * 60 + selectedMinute;

            int startTotalMinutes = startHour * 60 + startMinute;
            int endTotalMinutes = endHour * 60 + endMinute;

            if (selectedTotalMinutes >= startTotalMinutes && selectedTotalMinutes <= endTotalMinutes) {
              selectedStartTime=selectedTime;
              validTime=true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Appointment booked for ${selectedTime.format(context)}'),
                ),
              );
            } else {
              validTime=false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected time is outside working hours.'),
                ),
              );
            }
          }
        } else {
          validTime=false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Not enough available time for booking.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Working hours data is not available or incomplete.'),
          ),
        );
      }
    } catch (error) {
      print('Error updating timeline: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating timeline. Please try again.'),
        ),
      );
    }
  }

  Future<void> uploadToMechanicDailyTimeline({
    required BuildContext context,
    required String garageId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<String> services,
    required String carId,
  }) async {
    try {
      final CollectionReference appointmentsCollection = FirebaseFirestore.instance.collection('Bookedappointments');

      // Replace this with code to get the current user's UID from Firebase Authentication
      String currentUserUid = getCurrentUserUid(); // Replace this line with actual code

      await appointmentsCollection.add({

        'garageId': garageId,
        'date': date,
        'startTime': startTime.format(context),
        'endTime': endTime.format(context),
        'services': services,
        'userUid': currentUserUid,
        'carId': carId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking confirmed.'),
        ),
      );
      Navigator.of(context).pop();
      String formattedDate = DateFormat.yMd().format(date);
      NotificationHelper.initializeNotifications();
      String heading = 'Appointment booked on $formattedDate';
      String subHeading = 'Time: ${startTime.format(context)} - ${endTime.format(context)}';

// Show the notification with the heading and subheading
      NotificationHelper.showNotification(heading, subHeading);

      // After successfully adding the appointment, navigate to the appointment list screen

    } catch (error) {
      print('Error uploading appointment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming booking. Please try again.'),
        ),
      );
    }
  }



}

class Service {
  final String id;
  final String serviceName;
  final double price;
  final int performServiceTime;

  Service({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.performServiceTime,
  });
}

class CarSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cars;

  CarSelectionScreen({required this.cars});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Car'),
      ),
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cars[index]['carname'] ?? ''),//yeh change
            subtitle: Text(cars[index]['company'] ?? ''),
            onTap: () {
              Navigator.pop(context, cars[index]); // Pass the selected car back
            },
          );
        },
      ),
    );
  }
}

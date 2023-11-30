import 'package:autokaar/mechanicMod/checkout.dart';
import 'package:autokaar/userMod/editLogScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CarLogScreenMechanic extends StatefulWidget {
  final String carID;
  final Map<String, dynamic> appointmentData;
  final String garageID;

  CarLogScreenMechanic({required this.carID,required this.appointmentData, required this.garageID});

  @override
  State<CarLogScreenMechanic> createState() => _CarLogScreenMechanicState();
}

class _CarLogScreenMechanicState extends State<CarLogScreenMechanic> {
  TextEditingController _numberController = TextEditingController();
  final _numberFormatter = FilteringTextInputFormatter.digitsOnly; // Restrict input to digits

  late String currentMeter = '0';
  @override
  void initState() {
    super.initState();
    getCurrentMeterReading(widget.carID);


    // Call this method to fetch mechanics
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Log'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('carlog')
            .doc(widget.carID)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('No data available'),
            );
          }

          var logData = snapshot.data!.data() as Map<String, dynamic>;
          Timestamp frontright = logData['frontright'];
          Timestamp frontleft = logData['frontleft'];
          Timestamp backright = logData['backright'];
          Timestamp backleft = logData['backleft'];
          Timestamp service = logData['service'];
          String serviceRead = logData['serviceRead'];
          String frontrightRead = logData['frontrightRead'];
          String frontleftRead = logData['frontleftRead'];
          String backrightRead = logData['backrightRead'];
          String backleftRead = logData['backleftRead'];

          String frontrightF = 'frontright';
          String frontleftF = 'frontleft';
          String backrightF = 'backright';
          String backleftF = 'backleft';
          String serviceF = 'service';
          String serviceReadF = 'serviceRead';
          String frontrightReadF = 'frontrightRead';
          String frontleftReadF = 'frontleftRead';
          String backrightReadF = 'backrightRead';
          String backleftReadF = 'backleftRead';

          String frontrightTitle = 'Front Right Tyre';
          String frontleftTitle = 'Front Left Tyre';
          String backrightTitle = 'Back Right Tyre';
          String backleftTitle = 'Back left Tyre';
          String serviceTitle = 'Car Service';

          return SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _numberController,
                  inputFormatters: [_numberFormatter], // Apply the formatter
                  keyboardType: TextInputType.number, // Set the keyboard type to number
                  decoration: InputDecoration(
                    labelText: 'Enter current meter Reading',
                    hintText: '12345',
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    String numericInput = _numberController.text;

                    if (isInputValid(numericInput,convertToInt(currentMeter))) {
                      int numericValue = int.parse(numericInput);
                      print('Valid Numeric Value: $numericValue');
                      updateCarField(widget.carID,_numberController.text);
                    } else {
                      print('Invalid Input: Please enter a number greater than last meter reading');
                    }
                  },
                  child: Text('Update Meter Reading'),
                ),

                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    currentMeter,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCard(
                        frontleftTitle,
                        widget.carID,
                        formatTimestamp(frontleft),
                        frontleftRead,
                        frontleftF,
                        frontleftReadF,
                        context,
                      ),
                      Divider(),

                      _buildCard(
                        frontrightTitle,
                        widget.carID,
                        formatTimestamp(frontright),
                        frontrightRead,
                        frontrightF,
                        frontrightReadF,
                        context,
                      ),
                      Divider(),
                      _buildCard(
                        backleftTitle,
                        widget.carID,
                        formatTimestamp(backleft),
                        backleftRead,
                        backleftF,
                        backleftReadF,
                        context,
                      ),
                      Divider(),
                      _buildCard(
                        backrightTitle,
                        widget.carID,
                        formatTimestamp(backright),
                        backrightRead,
                        backrightF,
                        backrightReadF,
                        context,
                      ),
                      Divider(),
                      _buildCard(
                        serviceTitle,
                        widget.carID,
                        formatTimestamp(service),
                        serviceRead,
                        serviceF,
                        serviceReadF,
                        context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [




            // Confirm Booking Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckOutAppointment(appointmentData:widget.appointmentData, garageId: widget.garageID),
                  ),
                );

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
                    'CheckOut',
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
  bool isInputValid(String input,int minNum) {
    if (input.isEmpty) {
      return false; // Input is empty
    }
    int? numericValue = int.tryParse(input);
    return numericValue != null && numericValue > minNum;
  }

  Widget _buildCard(
      String fieldTitle,
      String carID,
      String value,
      String reading,
      String fieldTime,
      String fieldRead,
      BuildContext context,
      ) {
    final title = fieldTitle != null ? fieldTitle : "Title";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditReadingScreen(
              careId: carID,
              value: value,
              reading: reading,
              fieldTime: fieldTime,
              fieldRead: fieldRead,
              context: context,
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.directions_car),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              reading,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Car Run:',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Text(findDifference(currentMeter, reading))
          ],
        ),
      ),
    );
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMd().format(dateTime);
    String formattedTime = DateFormat.jm().format(dateTime);

    return '$formattedDate $formattedTime';
  }

  Future<String> getCurrentMeterReading(String carId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('userCar')
          .doc(carId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        setState(() {
          currentMeter = data?["current"] ?? '';
          print(currentMeter);
          print("currentMeter");
        });

        return currentMeter;
      } else {
        return '0';
      }
    } catch (e) {
      print('Error retrieving current meter reading: $e');
      return '0';
    }
  }

  String findDifference(String number1, String number2) {
    try {
      int num1 = int.parse(number1);
      int num2 = int.parse(number2);
      int difference = num1 - num2;
      return difference.toString();
    } catch (e) {
      return "No data found";
    }
  }

  int convertToInt(String numberString) {
    try {
      return int.parse(numberString);
    } catch (e) {
      return 0; // Return 0 if the conversion fails or the string is empty
    }
  }

  Future<void> updateCarField(String carId, String updatedValue) async {
    try {

      FirebaseFirestore firestore = FirebaseFirestore.instance;


      CollectionReference userCarCollection = firestore.collection('userCar');


      await userCarCollection.doc(carId).update({
        'current': updatedValue,
      });

      print('Document successfully updated with new value: $updatedValue');
    } catch (error) {
      print('Error updating document: $error');
    }
  }
}

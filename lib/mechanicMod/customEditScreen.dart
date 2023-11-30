import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCustomAutoPartScreen extends StatefulWidget {
  final String customPartId;

  EditCustomAutoPartScreen({required this.customPartId});

  @override
  _EditCustomAutoPartScreenState createState() =>
      _EditCustomAutoPartScreenState();
}

class _EditCustomAutoPartScreenState extends State<EditCustomAutoPartScreen> {
  TextEditingController _newReadingController = TextEditingController();
  String currentMeter = ''; // Replace with your actual currentMeter value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Custom Auto Part'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customLog')
            .doc(widget.customPartId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Custom auto part not found.'),
            );
          }

          var doc = snapshot.data!;
          var autoPartName = doc['autoPartName'];
          var lastChangeReading = doc['lastChangeReading'];
          var timestamp = doc['timestamp'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto Part Name: $autoPartName',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Last Change Reading: $lastChangeReading'),
                Text('Added: ${timestamp.toDate()}'),
                SizedBox(height: 20),
                Text(
                  'Update Reading:',
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: _newReadingController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter new reading',
                    hintText: 'New reading must be greater than current reading',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String newReading = _newReadingController.text;

                    if (isInputValid(newReading, convertToInt(currentMeter))) {
                      // Convert new reading to int
                      int newReadingValue = int.parse(newReading);
                      updateCustomAutoPart(widget.customPartId,newReadingValue);

                      // TODO: Add your database update logic here
                      // You need to update the 'lastChangeReading' field in the Firestore database with the new readingValue

                      // After updating the database, navigate back to the previous screen
                      Navigator.pop(context);
                    } else {
                      // Show an error message if the input is invalid
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Invalid Input'),
                            content: Text(
                                'Please enter a number greater than the current reading.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {


                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Save Update'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  void updateCustomAutoPart(String customPartId, int newReadingValue) {
    FirebaseFirestore.instance
        .collection('customLog')
        .doc(customPartId)
        .update({'customLog':Timestamp.now(),'lastChangeReading': newReadingValue.toString()})
        .then((_) {
      print('Custom auto part updated successfully.');
    }).catchError((error) {
      print('Error updating custom auto part: $error');
    });
  }

  int convertToInt(String value) {
    try {
      return int.parse(value);
    } catch (e) {
      return 0;
    }
  }

  bool isInputValid(String input, int currentReading) {
    try {
      int newReading = int.parse(input);
      return newReading > currentReading;
    } catch (e) {
      return false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditReadingScreen extends StatelessWidget {
  final String careId;
  final String value;
  final String reading;
  final String fieldTime;
  final String fieldRead;

  EditReadingScreen({
    required this.careId,
    required this.value,
    required this.reading,
    required this.fieldTime,
    required this.fieldRead,
    required BuildContext context,
  });

  @override
  Widget build(BuildContext context) {
    final newReadingCon = TextEditingController();
    int lastreading = convertToInt(reading);
    int localreading = 0;
    bool issueInReading = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Reading'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Title: $careId',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Value: $value',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Last Meter Reading:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              reading,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: newReadingCon,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New Meter Reading',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  issueInReading = true;
                  return 'Please enter a number.';
                }
                int newReading = convertToInt(value);
                if (newReading <= lastreading) {
                  issueInReading = true;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                          'new meter reading should higher than last reading.')));
                  return 'new meter reading should higher than $lastreading.';
                }
                if (newReading >= lastreading) {
                  issueInReading = false;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      backgroundColor: Colors.greenAccent,
                      content: Text('Valid Meter Reading')));
                  return 'new meter reading should higher than $lastreading.';
                }
                return null; // Return null to indicate the input is valid
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (newReadingCon.text.isNotEmpty) {
                  int newReading = convertToInt(newReadingCon.text.toString());
                  if (newReading <= lastreading) {
                    issueInReading = true;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                            'new meter reading should higher than last reading.')));
                  }
                  if (newReading >= lastreading) {
                    issueInReading = true;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Valid Updated Reading')));
                    String value = await updateLogField(
                        careId,
                        fieldRead,
                        fieldTime,
                        newReadingCon.text.toString(),
                        Navigator.pop(context));
                  }
                  //////////////
                }

                // Close the current screen
              },
              child: Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> updateLogField(String carIDM, String field, String fieldTime,
      dynamic value, void pop) async {
    String res = "Some error occurred";
    try {
      await FirebaseFirestore.instance
          .collection('carlog')
          .doc(carIDM)
          .update({field: value, fieldTime: Timestamp.now()});
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  int convertToInt(String numberString) {
    try {
      return int.parse(numberString);
    } catch (e) {
      return 0; // Return 0 if the conversion fails or the string is empty
    }
  }
}

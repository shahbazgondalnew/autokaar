import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  ReminderScreen({required this.data});

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late String currentReading = '0';

  @override
  void initState() {
    super.initState();
    fetchCurrentReading('5fe26210-6d7f-11ee-a185-c32f361999a1');
  }

  Future<void> fetchCurrentReading(String carID) async {
    try {
      DocumentSnapshot carSnapshot = await FirebaseFirestore.instance
          .collection('userCar')
          .doc(carID)
          .get();

      setState(() {
        currentReading = carSnapshot['current'].toString();
      });
    } catch (e) {
      print('Error fetching current reading: $e');
      // Handle the error as needed
    }
  }

  double calculatePositiveGap() {
    // Calculate the gap
    double gap = double.parse(currentReading) - widget.data['addtimerun'];

    // Take the absolute value to ensure it's positive
    double positiveGap = gap.abs();

    return positiveGap;
  }

  double calculatePercentageWithinAverageLife() {
    double averageLife = (widget.data['averageLife'] as num).toDouble();
    double currentRun = calculatePositiveGap();

    // Calculate the percentage within average life
    double percentage = (currentRun / averageLife) * 100;

    return percentage;
  }

  bool isExceededAverageLife() {
    double averageLife = (widget.data['averageLife'] as num).toDouble();
    double currentRun = calculatePositiveGap();

    return currentRun > averageLife;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoBox('Part Name', widget.data['name'], Icons.build),
              buildPartRunInfo(),
              buildInfoBox('Quantity', widget.data['quantity'].toString(),
                  Icons.shopping_cart),
              buildInfoBox('Reading at Updation',
                  widget.data['addtimerun'].toString(), Icons.timer),
              buildInfoBox('Average Life',
                  widget.data['averageLife'].toString(), Icons.timeline),
              buildInfoBox('Current Reading', currentReading, Icons.timeline),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoBox(String label, String value, IconData iconData) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                iconData,
                size: 28.0,
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPartRunInfo() {
    double currentRun = calculatePositiveGap();
    double percentageWithinAverageLife = calculatePercentageWithinAverageLife();
    bool exceededAverageLife = isExceededAverageLife();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildInfoBox(
            'Part Run', currentRun.toStringAsFixed(2), Icons.directions_run),
        SizedBox(height: 8.0),
        exceededAverageLife
            ? buildExceededAverageLifeInfo(percentageWithinAverageLife)
            : buildWithinAverageLifeInfo(percentageWithinAverageLife),
      ],
    );
  }

  Widget buildWithinAverageLifeInfo(double percentageWithinAverageLife) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Within Average Life',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28.0,
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                '${percentageWithinAverageLife.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildExceededAverageLifeInfo(double percentageWithinAverageLife) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exceeded Average Life',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 28.0,
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                '${percentageWithinAverageLife.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

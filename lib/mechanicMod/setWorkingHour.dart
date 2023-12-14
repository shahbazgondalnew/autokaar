import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetWorkingHoursScreen extends StatefulWidget {
  final String garageId;

  SetWorkingHoursScreen({required this.garageId});

  @override
  _SetWorkingHoursScreenState createState() => _SetWorkingHoursScreenState();
}

class _SetWorkingHoursScreenState extends State<SetWorkingHoursScreen> {
  List<TimeOfDay?> startTimes =
      List.generate(7, (index) => TimeOfDay(hour: 9, minute: 0));
  List<TimeOfDay?> endTimes =
      List.generate(7, (index) => TimeOfDay(hour: 18, minute: 0));
  List<bool> closedDays = List.generate(7, (index) => false);

  @override
  void initState() {
    super.initState();
    _fetchWorkingHours(); // Load data when the screen is opened
  }

  Future<void> _fetchWorkingHours() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('garages')
          .doc(widget.garageId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> workingHoursData = docSnapshot.get('workingHours');

        if (workingHoursData != null) {
          setState(() {
            for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
              Map<String, dynamic> dayData = workingHoursData['days'][dayIndex];
              int startHour = dayData['startHour'];
              int startMinute = dayData['startMinute'];
              int endHour = dayData['endHour'];
              int endMinute = dayData['endMinute'];

              startTimes[dayIndex] =
                  TimeOfDay(hour: startHour, minute: startMinute);
              endTimes[dayIndex] = TimeOfDay(hour: endHour, minute: endMinute);
              closedDays[dayIndex] = dayData['closed'];
            }
          });
        }
      }
    } catch (error) {
      print('Error fetching working hours: $error');
    }
  }

  Future<void> _selectStartTime(BuildContext context, int dayIndex) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTimes[dayIndex]!,
    );
    if (picked != null && picked != startTimes[dayIndex]) {
      setState(() {
        startTimes[dayIndex] = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context, int dayIndex) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTimes[dayIndex]!,
    );
    if (picked != null && picked != endTimes[dayIndex]) {
      setState(() {
        endTimes[dayIndex] = picked;
      });
    }
  }

  void _toggleClosed(int dayIndex) {
    setState(() {
      closedDays[dayIndex] = !closedDays[dayIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Working Hours'),
      ),
      body: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, dayIndex) {
          return ListTile(
            title: Text('${_getDayName(dayIndex)}'),
            subtitle: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectStartTime(context, dayIndex),
                  child: Text(
                    'Start: ${startTimes[dayIndex]!.format(context)}',
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _selectEndTime(context, dayIndex),
                  child: Text(
                    'End: ${endTimes[dayIndex]!.format(context)}',
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _toggleClosed(dayIndex),
                  style: ElevatedButton.styleFrom(
                    primary: closedDays[dayIndex] ? Colors.red : null,
                  ),
                  child: Text(
                    closedDays[dayIndex] ? 'Open' : 'Close',
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveWorkingHours();
          Navigator.pop(context);
        },
        icon: Icon(Icons.save),
        label: Text('Save Working Hours'),
      ),
    );
  }

  Future<void> _saveWorkingHours() async {
    try {
      List<Map<String, dynamic>> daysData = [];

      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
        daysData.add({
          'startHour': startTimes[dayIndex]!.hour,
          'startMinute': startTimes[dayIndex]!.minute,
          'endHour': endTimes[dayIndex]!.hour,
          'endMinute': endTimes[dayIndex]!.minute,
          'closed': closedDays[dayIndex],
        });
      }

      Map<String, dynamic> workingHoursData = {'days': daysData};

      await FirebaseFirestore.instance
          .collection('garages')
          .doc(widget.garageId)
          .set({'workingHours': workingHoursData}, SetOptions(merge: true));

      print('Working hours saved successfully');
    } catch (error) {
      print('Error saving working hours: $error');
    }
  }

  String _getDayName(int dayIndex) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[dayIndex];
  }
}

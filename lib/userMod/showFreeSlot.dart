import 'package:flutter/material.dart';

class SelectSlotScreen extends StatelessWidget {
  final Map<String, dynamic> workingHours;
  final List<Map<String, String>> bookedSlots;
  final int? slotDurationInMinutes;

  SelectSlotScreen({
    required this.workingHours,
    required this.bookedSlots,
    this.slotDurationInMinutes,
  });

  List<String> generateTimeSlots() {
    final int startHour = workingHours['startHour'] ?? 0;
    final int startMinute = workingHours['startMinute'] ?? 0;
    final int endHour = workingHours['endHour'] ?? 0;
    final int endMinute = workingHours['endMinute'] ?? 0;

    List<String> timeSlots = [];

    int currentHour = startHour;
    int currentMinute = startMinute;

    if (slotDurationInMinutes != null && slotDurationInMinutes! > 0) {
      while (currentHour < endHour ||
          (currentHour == endHour && currentMinute < endMinute)) {
        String startTime =
            '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
        currentMinute += slotDurationInMinutes!.toDouble().toInt();
        if (currentMinute >= 60) {
          currentHour++;
          currentMinute -= 60;
        }
        String endTime =
            '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
        timeSlots.add('$startTime - $endTime');
      }
    }

    return timeSlots;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> timeSlots = generateTimeSlots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select TimeSlot'),
      ),
      body: ListView.builder(
        itemCount: timeSlots.length,
        itemBuilder: (context, index) {
          final slot = timeSlots[index];
          final isBooked = bookedSlots.any((bookedSlot) {
            final startTime = slot.split(' - ')[0];
            final endTime = slot.split(' - ')[1];
            return (startTime == (bookedSlot['startTime'] ?? '') &&
                    endTime == (bookedSlot['endTime'] ?? '')) ||
                (startTime.compareTo(bookedSlot['startTime'] ?? '') >= 0 &&
                    startTime.compareTo(bookedSlot['endTime'] ?? '') < 0) ||
                (endTime.compareTo(bookedSlot['startTime'] ?? '') > 0 &&
                    endTime.compareTo(bookedSlot['endTime'] ?? '') <= 0);
          });

          return GestureDetector(
            onTap: isBooked ? null : () => onSlotTap(slot, context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isBooked ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(
                          12.0), // Adjust the value as needed
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isBooked ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    thickness: 1.0,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void onSlotTap(String slot, context) {
    Navigator.pop(context, slot);
  }
}

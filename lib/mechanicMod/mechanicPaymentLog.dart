import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentDataListScreen extends StatefulWidget {
  final String garageId;

  PaymentDataListScreen({required this.garageId});

  @override
  _PaymentDataListScreenState createState() => _PaymentDataListScreenState();
}

class _PaymentDataListScreenState extends State<PaymentDataListScreen> {
  List<Map<String, dynamic>> paymentData = [];
  bool showPaid = true; // Initially show paid data

  @override
  void initState() {
    super.initState();
    fetchPaymentData();
  }

  Future<void> fetchPaymentData() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot snapshot = await firestore
          .collection('paymentStatus')
          .where('garageId', isEqualTo: widget.garageId)
          .get();

      final List<Map<String, dynamic>> data = snapshot.docs
          .map((DocumentSnapshot doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        paymentData = data;
      });
    } catch (error) {
      // Handle error
      print('Error fetching payment data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Data List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Filter:'),
                SizedBox(width: 10),
                DropdownButton<bool>(
                  value: showPaid,
                  items: [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Paid'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('Unpaid'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      showPaid = value ?? true;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child:
            ListView.builder(
              itemCount: paymentData.length,
              itemBuilder: (context, index) {
                final payment = paymentData[index];
                final isPaid = payment['isPaid'] as bool;

                if ((showPaid && isPaid) || (!showPaid && !isPaid)) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentDetailScreen(
                            appointmentData: payment,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text('Appointment ID: ${payment['appointmentId']}'),
                      subtitle: Text('Total Price: ${payment['totalPrice']} PKR'),
                    ),
                  );
                }

                return Container(); // Empty container if not shown
              },
            ),
          ),
        ],
      ),
    );
  }
}


//

// AppointmentDetailScreen.dart



class AppointmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  AppointmentDetailScreen({required this.appointmentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appointment ID: ${appointmentData['appointmentId']}'),
            Text('Total Price: ${appointmentData['totalPrice']} PKR'),
            Text('Total Time: ${appointmentData['totalTime']} mins'),
            Text('Is Paid: ${appointmentData['isPaid'] ? 'Paid' : 'Unpaid'}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}



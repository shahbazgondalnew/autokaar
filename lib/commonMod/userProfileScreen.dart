import 'package:autokaar/commonMod/loginMain.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreenX extends StatefulWidget {
  final User user;

  const UserProfileScreenX({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfileScreenXState createState() => _UserProfileScreenXState();
}

class _UserProfileScreenXState extends State<UserProfileScreenX> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  String _currentName = '';
  String _currentCity = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
    fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void fetchUserData() async {
    final userDataSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.user.uid)
        .get();

    if (userDataSnapshot.exists) {
      final userData = userDataSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _currentName = userData['name'] ?? '';
        _currentCity = userData['city'] ?? '';
        _nameController.text = _currentName;
        _cityController.text = _currentCity;
      });
    }
  }

  void updateUserData() async {
    final newName = _nameController.text;
    final newCity = _cityController.text;


    await FirebaseFirestore.instance.collection('Users').doc(widget.user.uid).update({
      'name': newName,
      'city': newCity,
    });

    setState(() {
      _currentName = newName;
      _currentCity = newCity;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${widget.user.email}', style: TextStyle(color: Colors.white)),
            ListTile(
              title: Text('Name:', style: TextStyle(color: Colors.white)),
              subtitle: Text(_currentName, style: TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.green),
                onPressed: () {
                  showEditDialog(context, 'Edit Name', _nameController);
                },
              ),
            ),
            ListTile(
              title: Text('City:', style: TextStyle(color: Colors.white)),
              subtitle: Text(_currentCity, style: TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.green),
                onPressed: () {
                  showEditDialog(context, 'Edit City', _cityController);
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                logout(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8.0),
                  Text('Logout', style: TextStyle(color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 5, // Button elevation
                minimumSize: Size(double.infinity, 0), // Full width
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showEditDialog(BuildContext context, String title, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: title,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () {
                updateUserData();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void logout(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signOut();


      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => MyLoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {

      print('Error logging out: $e');
    }
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autokaar/userMod/mainScreenApp.dart';

class MyAppSignUp extends StatefulWidget {
  const MyAppSignUp({Key? key}) : super(key: key);
//MyAppSignUp
  @override
  _MyAppSignUpState createState() => _MyAppSignUpState();
}

class _MyAppSignUpState extends State<MyAppSignUp> {
  @override
  Widget build(BuildContext context) {
    const appTitle = 'Sign Up';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(appTitle),
        ),
        body: const SignUpForm(),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<SignUpForm> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final showEmpty = SnackBar(
      content: Text('Imformation can not be empty'),
      backgroundColor: Colors.red);
  final notEmpty = SnackBar(content: Text('Imformation is not empty'));
  final invalidEmail =
      SnackBar(content: Text('Invalid Email'), backgroundColor: Colors.red);
  final validEmail = SnackBar(content: Text('Valid  Email'));
  final passLength = SnackBar(
      content: Text('Length can not be less tha 6'),
      backgroundColor: Colors.red);
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
    cityController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 20),
        SizedBox(height: 20),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
              hintText: 'Email',
              contentPadding: const EdgeInsets.all(15),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
          onChanged: (value) {},
        ),
        SizedBox(height: 20),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
              hintText: 'Name',
              contentPadding: const EdgeInsets.all(15),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
          onChanged: (value) {},
        ),
        SizedBox(height: 20),
        TextField(
          controller: passController,
          decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: const EdgeInsets.all(15),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
          onChanged: (value) {},
        ),
        SizedBox(height: 20),
        TextField(
          controller: cityController,
          decoration: InputDecoration(
              hintText: 'City',
              contentPadding: const EdgeInsets.all(15),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
          onChanged: (value) {},
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        shape: MaterialStateProperty
                            .all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: const BorderSide(color: Colors.black)))),
                    child: const Text("Create Account"),
                    onPressed: () async {
                      if (cityController.text.isEmpty ||
                          nameController.text.isEmpty ||
                          passController.text.isEmpty ||
                          emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(showEmpty);
                      } else {
                        var email = emailController.text.toString();
                        bool isValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(email);

                        if (isValid == true) {
                          if (passController.text.length < 6) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(passLength);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(validEmail);
                            String emailData = emailController.text;
                            String passData = passController.text;
                            String cityData = cityController.text;
                            String nameData = nameController.text;
                            print(emailData);
                            print(passData);

                            try {
                              // ignore: unused_local_variable
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .createUserWithEmailAndPassword(
                                      email: emailData, password: passData);
                              userSetup(nameData, cityData, emailData);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainScreen()),
                              );
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'The password provided is too weak.')));
                              } else if (e.code == 'email-already-in-use') {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'The account already exists for that email.'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            } catch (e) {
                              print(e);
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(invalidEmail);
                        }
                      }
                    })),
          ],
        ),
      ],
    );
  }

  Future<void> userSetup(String displayName, String city, String email) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();
    print(uid);
    print('Users/$uid');

    await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'email': email,
      'name': displayName,
      'city': city,
    });

    return;
  }
}

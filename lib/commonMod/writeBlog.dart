import 'dart:io';
import 'blogClass.dart';

import 'package:autokaar/userMod/postClass.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

// ignore: camel_case_types
class blogdata extends StatefulWidget {
  const blogdata({Key? key}) : super(key: key);

  @override
  _blogdataState createState() => _blogdataState();
}

// ignore: camel_case_types
class _blogdataState extends State<blogdata> {
  String city = 'empty';
  String name = 'empty';

  late Future<String> uploadd;
  late String imageUrln;
  String RegionS = 'All';
  String printt = 'empty';
  var photolink = '';
  var lengthOfPost;
  late QuerySnapshot save;
  final longBlogText = TextEditingController();
  final titleController = TextEditingController();
  File? _imageFileshow;

  Future<void> _pickImageshow(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFileshow = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.6;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Write Blog'),
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                hintText: 'Title',
                contentPadding: const EdgeInsets.all(15),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30))),
            onChanged: (value) {},
          ),const Divider(),
              TextField(
                controller: longBlogText,
                keyboardType: TextInputType.multiline,
                maxLines: null, // Allow multiple lines of input
                decoration: InputDecoration(
                  hintText: 'Write your blog',
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {},
              ),
              const Divider(),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Photo Library'),
                              onTap: () {
                                _pickImageshow(ImageSource.gallery);
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_camera),
                              title: Text('Camera'),
                              onTap: () {
                                _pickImageshow(ImageSource.camera);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300],
                    image: _imageFileshow != null
                        ? DecorationImage(
                            image: FileImage(_imageFileshow!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFileshow == null
                      ? Icon(
                          Icons.add_a_photo,
                          size: 70,
                          //50
                          color: Colors.grey[800],
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),


          const Divider(),
        ])),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Time and Total Price

            SizedBox(height: 16),


            ElevatedButton(
              onPressed: () {
                uploadImage();
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
                    'Add Blog',
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

  Future<void> uploadImage() async {
    final firebaseStorage = FirebaseStorage.instance;
    if (_imageFileshow != null) {
      String postname = const Uuid().v1();
      var snapshot = await firebaseStorage
          .ref()
          .child('photos/$postname')
          .putFile(_imageFileshow!);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      FirebaseAuth auth = FirebaseAuth.instance;
      String cuid = auth.currentUser!.uid.toString();
      imageUrln = downloadUrl;
      // ignore: use_build_context_synchronously
      saveBlogPostToFirestore(context, cuid, imageUrln,
          titleController.text.toString(), longBlogText.text.toString());
    }
  }

  Future<void> saveBlogPostToFirestore(BuildContext context, String uploaderUid,
      String imageLink, String title, String textOfBlog) async {
    String blogId = const Uuid().v1();

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Map<String, dynamic> blogPost = {
        'blogID': blogId,
        'uploaderUid': uploaderUid,
        'imageLink': imageLink,
        'title': title,
        'textOfBlog': textOfBlog,
        'blogUploadTime': FieldValue.serverTimestamp(),
      };

      await firestore.collection('mechanicUserBlog').doc(blogId).set(blogPost);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Blog post saved to Firestore successfully!'),
          backgroundColor:
              Colors.green, // Set background color to green for success
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving blog post to Firestore: $e'),
          backgroundColor: Colors.red, // Set background color to red for errors
        ),
      );
    }
  }
}

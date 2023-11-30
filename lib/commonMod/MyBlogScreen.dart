import 'package:autokaar/commonMod/writeBlog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'blogDetialscreen.dart';

class MyBlogScreen extends StatelessWidget {
  String cuid = FirebaseAuth.instance.currentUser!.uid.toString();

  @override
  Widget build(BuildContext context) {
    print(cuid);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => blogdata()),
                );
              },
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              label: Text('Write Blog'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mechanicUserBlog')
                  .where('uploaderUid', isEqualTo: cuid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final blogs = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: blogs.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (context, index) {
                    final blog = blogs[index].data() as Map<String, dynamic>;
                    final imageLink = blog['imageLink'] ?? '';
                    final blogID = blog['blogID'] ?? '';
                    final uploaderID = blog['uploaderUid'] ?? '';
                    final title = blog['title'] ?? '';

                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlogDetailsScreen(
                              blogID: blogID,
                              uploaderID: uploaderID,
                            ),
                          ),
                        );
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageLink,
                          height: 200, // increase image size
                          width: 100, // increase image size
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16, // reduce text size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

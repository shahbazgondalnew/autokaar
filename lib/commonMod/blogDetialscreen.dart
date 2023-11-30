import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BlogDetailsScreen extends StatefulWidget {
  final String blogID;
  final String uploaderID;

  const BlogDetailsScreen({required this.blogID, required this.uploaderID});

  @override
  _BlogDetailsScreenState createState() => _BlogDetailsScreenState();
}

class _BlogDetailsScreenState extends State<BlogDetailsScreen> {
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mechanicUserBlog')
            .doc(widget.blogID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final blogData = snapshot.data!.data() as Map<String, dynamic>;
          final imageLink = blogData['imageLink'] ?? '';
          final title = blogData['title'] ?? '';
          String textOfBlog = blogData['textOfBlog'] ?? '';
          final updloadTime = blogData['blogUploadTime'] ?? '';

          int maxLength = 200; // Maximum length for each paragraph

          List<String> paragraphs = [];
          for (int i = 0; i < textOfBlog.length; i += maxLength) {
            int endIndex = i + maxLength;
            if (endIndex > textOfBlog.length) {
              endIndex = textOfBlog.length;
            }
            String paragraph = textOfBlog.substring(i, endIndex).trim();
            paragraphs.add(paragraph);
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageLink,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        title,
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        formatTimestamp(updloadTime),
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: paragraphs
                            .map((paragraph) => HtmlWidget(
                                  '<p>$paragraph</p>',
                                  textStyle:
                                      Theme.of(context).textTheme.bodyText1,
                                  // textAlign: TextAlign.justify,
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Enter comment',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {

                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (commentController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Error'),
                                content: Text('Comment cannot be empty.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            uploadCommentToFirebase(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        child: Text('Submit Comment'),
                      ),

                      SizedBox(height: 16),
                      FutureBuilder<int>(
                        future: getCommentsCountForBlog(blogData['blogID']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              'Total Comments: 0',
                              style: Theme.of(context).textTheme.bodyText2,
                            );
                          } else if (snapshot.hasData) {
                            return Text(
                              'Total Comments: ${snapshot.data}',
                              style: Theme.of(context).textTheme.bodyText2,
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text('No comments');
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .doc(widget.blogID)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final comments = snapshot.data!.docs;

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comment =
                            comments[index].data() as Map<String, dynamic>;
                        final commentText = comment['comment'];
                        final timestamp = formatTimestamp(comment['timestamp']);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(comment['uploaderID'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text('Loading...');
                                }

                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return Text('User not found');
                                }

                                final userData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                final username = userData['name'];

                                return Text(
                                  username,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            Text(
                              commentText,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Posted on: ${timestamp.toString()}',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 4),
                            Divider(),
                          ],
                        );
                      },
                      childCount: comments.length,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void uploadCommentToFirebase(BuildContext context) {
    final comment = commentController.text.trim();

    if (comment.isNotEmpty) {
      final commentData = {
        'comment': comment,
        'uploaderID': widget.uploaderID,
        'timestamp': FieldValue.serverTimestamp(),

      };

      FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.blogID)
          .collection('comments')
          .add(commentData)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload comment'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMd().format(dateTime);
    String formattedTime = DateFormat.jm().format(dateTime);

    return '$formattedDate $formattedTime';
  }

  Future<int> getCommentsCountForBlog(String blogID) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(blogID)
        .collection('comments')
        .get();

    final commentsCount = snapshot.docs.length;

    return commentsCount;
  }
}

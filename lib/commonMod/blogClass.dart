import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String title;
  final String uid;
  final String longText;
  final String urlS;
  final String arthor;
  final Timestamp uploadedtime;

  const Blog(
      {required this.title,
      required this.uid,
      required this.longText,
      required this.urlS,
      required this.arthor,
      required this.uploadedtime});

  static Blog fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Blog(
        title: snapshot["title"],
        uid: snapshot["uid"],
        longText: snapshot["longText"],
        urlS: snapshot["urlS"],
        arthor: snapshot["arthor"],
        uploadedtime: snapshot["uploadedtime"]);
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "uid": uid,
        "longText": longText,
        "urlS": urlS,
        "allData": "$title $arthor",
        "arthor": arthor,
        "uploadedtime": FieldValue.serverTimestamp()
      };
}

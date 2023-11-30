import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String carName;
  final String uid;
  final String company;
  final String urlS;
  final String region;
  final Timestamp timestamp;
  final String currentMeter;
  final String carModelname;
  final String carID;

  const Post({
    required this.carName,
    required this.uid,
    required this.company,
    required this.urlS,
    required this.region,
    required this.timestamp,
    required this.currentMeter,
    required this.carModelname,
    required this.carID,
  });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
        carName: snapshot["carname"],
        uid: snapshot["uid"],
        company: snapshot["company"],
        urlS: snapshot["urlS"],
        region: snapshot["region"],
        timestamp: snapshot["timestamp"],
        currentMeter: snapshot["current"],
        carModelname: snapshot["carModelname"],
        carID: snapshot["carID"]);
  }

  Map<String, dynamic> toJson() => {
        "carname": carName,
        "uid": uid,
        "company": company,
        "urlS": urlS,
        "allData": "$carName $company",
        "region": region,
        "timestamp": FieldValue.serverTimestamp(),
        "current": currentMeter,
        "carModel": carModelname,
        "carID": carID
      };
}

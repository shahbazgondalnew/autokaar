import 'package:cloud_firestore/cloud_firestore.dart';

class Garage {
  final String garageName;
  final String userID;
  final Map<String, double> googleLocation;
  final String imageUrl;
  final String statusOfGarage;
  final String garagenum;

  const Garage({
    required this.garageName,
    required this.userID,
    required this.googleLocation,
    required this.imageUrl,
    required this.statusOfGarage,
    required this.garagenum,
  });

  static Garage fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Garage(
        garageName: snapshot["garageName"],
        userID: snapshot["userID"],
        googleLocation: {
          "latitude": snapshot["googleLocation"]["latitude"],
          "longitude": snapshot["googleLocation"]["longitude"],
        },
        imageUrl: snapshot["imageUrl"],
        statusOfGarage: snapshot["statusOfGarage"],
        garagenum: snapshot["garagenum"]);
  }

  Map<String, dynamic> toJson() => {
        "garageName": garageName,
        "userID": userID,
        "googleLocation": {
          "latitude": googleLocation["latitude"],
          "longitude": googleLocation["longitude"],
        },
        "imageUrl": imageUrl,
        "statusOfGarage": statusOfGarage,
        "garagenum": garagenum
      };
}

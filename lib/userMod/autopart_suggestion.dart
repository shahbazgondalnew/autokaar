import 'package:autokaar/mechanicMod/showAutoparts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AutoPartSuggestion {
  Future<List<Autopart>> suggestAutoParts(
      String userId, List<Autopart> allAutoParts) async {
    UserCarInfo userCarInfo = await getUserCarInfoFromFirebase(userId);
    List<Autopart> suggestions = [];
    print("Suggested On the base of :");
    print(userCarInfo.toString());

    for (Autopart autoPart in allAutoParts) {
      double compatibilityScore =
          calculateCompatibilityScore(userCarInfo, autoPart);

<<<<<<< HEAD
=======
     
>>>>>>> 30986fdec5fa05c962032939b04e0ee056578c1b
      if (compatibilityScore > 0.7) {
        suggestions.add(autoPart);
      }
    }

<<<<<<< HEAD
=======
    
>>>>>>> 30986fdec5fa05c962032939b04e0ee056578c1b
    suggestions.sort((a, b) => calculateCompatibilityScore(userCarInfo, b)
        .compareTo(calculateCompatibilityScore(userCarInfo, a)));

    return suggestions;
  }

  double calculateCompatibilityScore(UserCarInfo userCar, Autopart autoPart) {
<<<<<<< HEAD
=======
   

   
>>>>>>> 30986fdec5fa05c962032939b04e0ee056578c1b
    bool isSuitable = autoPart.suitableCars.any((suitableCar) =>
        suitableCar.companyName.toLowerCase() ==
            userCar.company.toLowerCase() &&
        suitableCar.modelName.toLowerCase() == userCar.carModel.toLowerCase());

    if (isSuitable) {
      return 1.0;
    } else {
      return 0.0;
    }
  }

  Future<UserCarInfo> getUserCarInfoFromFirebase(String userId) async {
    QuerySnapshot<Map<String, dynamic>> userCarSnapshot =
        await FirebaseFirestore.instance
            .collection('userCar')
            .where('uid', isEqualTo: userId)
            .limit(1)
            .get();

    if (userCarSnapshot.docs.isNotEmpty) {
      Map<String, dynamic> data = userCarSnapshot.docs.first.data() ?? {};
      return UserCarInfo.fromMap(data);
    } else {
      print("issue");

      return UserCarInfo(
        carID: '',
        carModel: '',
        carName: '',
        company: '',
        current: '',
        region: '',
        timestamp: Timestamp.now(),
        uid: userId,
        urlS: '',
      );
    }
  }
}

class UserCarInfo {
  final String carID;
  final String carModel;
  final String carName;
  final String company;
  final String current;
  final String region;
  final Timestamp timestamp;
  final String uid;
  final String urlS;

  UserCarInfo({
    required this.carID,
    required this.carModel,
    required this.carName,
    required this.company,
    required this.current,
    required this.region,
    required this.timestamp,
    required this.uid,
    required this.urlS,
  });

  factory UserCarInfo.fromMap(Map<String, dynamic> data) {
    return UserCarInfo(
      carID: data['carID'] ?? '',
      carModel: data['carModel'] ?? '',
      carName: data['carName'] ?? '',
      company: data['company'] ?? '',
      current: data['current'] ?? '',
      region: data['region'] ?? '',
      timestamp: data['timestamp'] ?? '',
      uid: data['uid'] ?? '',
      urlS: data['urlS'] ?? '',
    );
  }
}

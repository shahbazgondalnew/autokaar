import 'package:autokaar/mechanicMod/showAutoparts.dart';

// Import your Autopart class or adjust accordingly
import 'package:cloud_firestore/cloud_firestore.dart';

class AutoPartSuggestion {
  Future<List<Autopart>> suggestAutoParts(
      String userId, List<Autopart> allAutoParts) async {
    UserCarInfo userCarInfo = await getUserCarInfoFromFirebase(userId);
    List<Autopart> suggestions = [];
    print("Suggested On the base of :"); //Autopart suggestion
    print(userCarInfo.toString());

    for (Autopart autoPart in allAutoParts) {
      double compatibilityScore =
          calculateCompatibilityScore(userCarInfo, autoPart);

      // Example: Consider auto parts with a compatibility score greater than a threshold
      if (compatibilityScore > 0.7) {
        suggestions.add(autoPart);
      }
    }

    // Sort suggestions by compatibility score in descending order
    suggestions.sort((a, b) => calculateCompatibilityScore(userCarInfo, b)
        .compareTo(calculateCompatibilityScore(userCarInfo, a)));

    return suggestions;
  }

  double calculateCompatibilityScore(UserCarInfo userCar, Autopart autoPart) {
    // Example: Implement your compatibility score calculation logic
    // Adjust this logic based on your data model and requirements

    // Check if there is any SuitableCar that matches both company and model
    bool isSuitable = autoPart.suitableCars.any((suitableCar) =>
        suitableCar.companyName.toLowerCase() ==
            userCar.company.toLowerCase() &&
        suitableCar.modelName.toLowerCase() == userCar.carModel.toLowerCase());

    if (isSuitable) {
      return 1.0; // Full compatibility
    } else {
      return 0.0; // No compatibility
    }
  }

  Future<UserCarInfo> getUserCarInfoFromFirebase(String userId) async {
    QuerySnapshot<Map<String, dynamic>> userCarSnapshot =
        await FirebaseFirestore.instance
            .collection('userCar')
            .where('uid', isEqualTo: userId)
            .limit(1) // Assuming there is at most one document per user
            .get();

    if (userCarSnapshot.docs.isNotEmpty) {
      // Use the first document if there are multiple (though it's expected to be only one)
      Map<String, dynamic> data = userCarSnapshot.docs.first.data() ?? {};
      return UserCarInfo.fromMap(data);
    } else {
      print("issue");
      // Handle the case where user car data doesn't exist
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

  // Factory method to create UserCarInfo from a Map (Firestore data)
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

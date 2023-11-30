import 'package:cloud_firestore/cloud_firestore.dart';

class carLog {
  final Timestamp frontright;
  final Timestamp frontleft;
  final Timestamp backright;
  final Timestamp backleft;

  final Timestamp service;
  final String serviceRead;

  final String frontrightRead;
  final String frontleftRead;
  final String backrightRead;
  final String backleftRead;

  final String frontrightReadTitle;
  final String frontleftReadTitle;
  final String backrightReadTitle;
  final String backleftReadTitle;
  final String serviceTitle;

  const carLog({
    required this.frontrightReadTitle,
    required this.frontleftReadTitle,
    required this.backrightReadTitle,
    required this.backleftReadTitle,
    required this.serviceTitle,
    required this.frontright,
    required this.frontleft,
    required this.backright,
    required this.backleft,
    required this.service,
    required this.serviceRead,
    required this.frontrightRead,
    required this.frontleftRead,
    required this.backrightRead,
    required this.backleftRead,
  });

  static carLog fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return carLog(
      frontright: snapshot["frontright"],
      frontleft: snapshot["frontleft"],
      backright: snapshot["backright"],
      backleft: snapshot["backleft"],
      service: snapshot["service"],
      serviceRead: snapshot["serviceRead"],
      frontrightRead: snapshot["frontrightRead"],
      frontleftRead: snapshot["frontleftRead"],
      backrightRead: snapshot["backrightRead"],
      backleftRead: snapshot["backleftRead"],
      frontrightReadTitle: snapshot["frontrightTitle"],
      frontleftReadTitle: snapshot["frontleftTitle"],
      backrightReadTitle: snapshot["backrightTitle"],
      backleftReadTitle: snapshot["backleftTitle"],
      serviceTitle: snapshot["serviceTitle"],
    );
  }

  Map<String, dynamic> toJson() => {
        "frontright": frontright,
        "frontleft": frontleft,
        "backright": backright,
        "backleft": backleft,
        "service": service,
        "frontrightTitle": frontrightReadTitle,
        "frontleftTitle": frontleftReadTitle,
        "backrightTitle": backrightReadTitle,
        "backleftTitle": backleftReadTitle,
        "serviceTitle": serviceTitle,
        "serviceRead": serviceRead,
        "frontrightRead": frontrightRead,
        "frontleftRead": frontleftRead,
        "backrightRead": backrightRead,
        "backleftRead": backleftRead,
      };
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WaterMonitor {
  DateTime date;
  int waterVolume;
  String dateString;
  String drinkTime;
  String documentID;

  final DocumentReference reference;

  WaterMonitor.fromSnapshot(DocumentSnapshot snapshot)
      : reference = snapshot.reference,
        date = snapshot.data['date'].toDate(),
        dateString =
            DateFormat('yyyyMMdd').format(snapshot.data['date'].toDate()),
        drinkTime = snapshot.data['drinkTime'],
        waterVolume = snapshot.data["waterVolume"],
        documentID = snapshot.documentID;
}

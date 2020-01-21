import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SleepMonitor {
  DateTime date;
  int sleepHours;
  String dateString;
  String startTime;
  String endTime;

  final DocumentReference reference;

  SleepMonitor.fromSnapshot(DocumentSnapshot snapshot)
      : reference = snapshot.reference,
        date = snapshot.data['date'].toDate(),
        sleepHours = snapshot.data["sleepHours"],
        startTime = snapshot.data["startTime"],
        endTime = snapshot.data["endTime"],
        dateString =
            DateFormat('yyyyMMdd').format(snapshot.data['date'].toDate());
}

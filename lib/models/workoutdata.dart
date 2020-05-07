import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WorkoutMonitor {
  DateTime date;
  int steps;
  String dateString;
  int run;
  int cycling;
  int etc;
  final DocumentReference reference;

  WorkoutMonitor.fromSnapshot(DocumentSnapshot snapshot)
      : reference = snapshot.reference,
        date = snapshot.data['date'].toDate(),
        steps = snapshot.data["steps"],
        run = snapshot.data["run"],
        cycling = snapshot.data["cycling"],
        etc = snapshot.data["etc"],
        dateString =
            DateFormat('yyyyMMdd').format(snapshot.data['date'].toDate());
}

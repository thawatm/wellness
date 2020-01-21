import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FoodMonitor {
  DateTime date;
  String imageUrl;
  String uploadPath;
  String menu;
  String dateString;
  String calories;
  int totalCalories;
  String documentID;
  int eatHours;

  FoodMonitor(
      {this.date,
      this.dateString,
      this.totalCalories,
      this.eatHours,
      this.reference});

  final DocumentReference reference;

  FoodMonitor.fromSnapshot(DocumentSnapshot snapshot)
      : reference = snapshot.reference,
        date = snapshot.data['date'].toDate(),
        dateString =
            DateFormat('yyyyMMdd').format(snapshot.data['date'].toDate()),
        imageUrl = snapshot.data['imageUrl'],
        uploadPath = snapshot.data['uploadPath'],
        menu = snapshot.data['menu'] ?? '',
        calories = snapshot.data["calories"] ?? '0',
        totalCalories = int.parse(snapshot.data["calories"]),
        documentID = snapshot.documentID;

  Map getMapData() {
    Map<String, dynamic> mapData = {
      'date': this.date,
      'imageUrl': this.imageUrl,
      'uploadPath': this.uploadPath,
      'menu': this.menu,
      'calories': this.calories,
    };
    return mapData;
  }
}

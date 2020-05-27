import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FoodMonitor {
  DateTime date;
  String imageUrl;
  String uploadPath;
  String menu;
  String dateString;
  String serving;
  int totalServing;
  String documentID;
  int eatHours;

  FoodMonitor(
      {this.date,
      this.dateString,
      this.totalServing,
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
        serving = snapshot.data["serving"] ?? '0',
        totalServing = int.parse(snapshot.data["serving"] ?? '0'),
        documentID = snapshot.documentID;

  Map getMapData() {
    Map<String, dynamic> mapData = {
      'date': this.date,
      'imageUrl': this.imageUrl,
      'uploadPath': this.uploadPath,
      'menu': this.menu,
      'serving': this.serving,
    };
    return mapData;
  }
}

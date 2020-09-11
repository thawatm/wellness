import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness/models/userdata.dart';

class GroupData {
  String name;
  String owner;
  List<UserProfile> members;

  final DocumentReference reference;

  GroupData.fromSnapshot(DocumentSnapshot snapshot)
      : reference = snapshot.reference,
        name = snapshot.data()['name'],
        owner = snapshot.data()["owner"];
}

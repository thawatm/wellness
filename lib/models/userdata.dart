import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String firstname;
  String lastname;
  String fullname;
  String phoneNumber;
  String email;
  String uid;

  DateTime birthday;

  String sex;
  int height;
  String bloodGroup;
  String expense;

  String lineId;
  String citizenId;
  String address;

  bool isDrugAllergy = false;
  bool isFoodAllergy = false;
  bool isDrugAllergySuspect = false;
  String drugAllergy;
  String diagnoseHospital;
  String treatmentHospital;
  String doctor;
  String allergySymptom;
  String suspectSymptom;
  String foodAllergy;
  String ingredientAllergy;

  String pictureUrl;
  bool smoke = false;

  final DocumentReference reference;

  UserProfile.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['firstName'] != null),
        assert(map['lastName'] != null),
        assert(map['phoneNumber'] != null),
        assert(map['email'] != null),
        assert(map['uid'] != null),
        firstname = map['firstname'],
        lastname = map['lastname'],
        phoneNumber = map['phoneNumber'],
        email = map['email'],
        uid = map['uid'];

  // UserProfile.fromSnapshot(DocumentSnapshot snapshot)
  // : this.fromMap(snapshot.data, reference: snapshot.reference);
  UserProfile.fromSnapshot(DocumentSnapshot snapshot)
      : reference = snapshot.reference,
        uid = snapshot.data['uid'],
        firstname = snapshot.data['firstname'],
        lastname = snapshot.data['lastname'],
        fullname = (snapshot.data['firstname'] ?? '') +
            ' ' +
            (snapshot.data['lastname'] ?? ''),
        phoneNumber = snapshot.data['phoneNumber'],
        email = snapshot.data['email'],
        sex = snapshot.data['sex'],
        height = snapshot.data['height'],
        bloodGroup = snapshot.data['bloodGroup'],
        expense = snapshot.data['expense'],
        lineId = snapshot.data['lineId'],
        citizenId = snapshot.data['citizenId'],
        address = snapshot.data['address'],
        isDrugAllergy = snapshot.data['isDrugAllergy'],
        isDrugAllergySuspect = snapshot.data['isDrugAllergySuspect'],
        isFoodAllergy = snapshot.data['isFoodAllergy'],
        drugAllergy = snapshot.data['drugAllergy'],
        diagnoseHospital = snapshot.data['diagnoseHospital'],
        doctor = snapshot.data['doctor'],
        treatmentHospital = snapshot.data['treatmentHospital'],
        suspectSymptom = snapshot.data['suspectSymptom'],
        allergySymptom = snapshot.data['allergySymptom'],
        foodAllergy = snapshot.data['foodAllergy'],
        ingredientAllergy = snapshot.data['ingredientAllergy'],
        smoke = snapshot.data['smoke'],
        pictureUrl = snapshot.data['pictureUrl'];
  // birthday = snapshot.data['birthday'].toDate();

  @override
  String toString() => "UserProfile<$phoneNumber:$firstname>";
}

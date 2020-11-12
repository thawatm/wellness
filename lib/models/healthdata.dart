import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HealthMonitor {
  DateTime date;
  String dateString;
  String kioskDocumentId;
  String category;
  num pressureUpper;
  num pressureLower;
  num hr;
  num weight;
  num height;
  num bmi;
  num rightArmFat;
  num leftArmFat;
  num rightLegFat;
  num leftLegFat;
  num trunkFat;
  num bodyFat;
  num visceralFat;
  num muscle;
  num waist;

  num hba1c;
  num bodyAge;
  num glucose;
  num cholesterol;
  num hdl;
  num ldl;
  num triglycerides;
  num creatinine;
  num eGFR;
  num uricAcid;
  num alt;
  num alp;
  num ast;

  final DocumentReference reference;
  final DocumentSnapshot snapshot;

  HealthMonitor.fromSnapshot(DocumentSnapshot snapshot)
      : reference = snapshot.reference,
        snapshot = snapshot,
        date = snapshot.data()['date'].toDate(),
        kioskDocumentId = snapshot.data()['kioskDocumentId'],
        category = snapshot.data()['category'],
        dateString =
            DateFormat('dd/MM/yyyy').format(snapshot.data()['date'].toDate()),
        pressureUpper = snapshot.data()["pressureUpper"],
        pressureLower = snapshot.data()["pressureLower"],
        hr = snapshot.data()["hr"],
        weight = snapshot.data()["weight"],
        height = snapshot.data()["height"],
        bmi = snapshot.data()["bmi"],
        rightArmFat = snapshot.data()["rightArmFat"],
        leftArmFat = snapshot.data()["leftArmFat"],
        rightLegFat = snapshot.data()["rightLegFat"],
        leftLegFat = snapshot.data()["leftLegFat"],
        trunkFat = snapshot.data()["trunkFat"],
        bodyAge = snapshot.data()["bodyAge"],
        bodyFat = snapshot.data()["bodyFat"],
        visceralFat = snapshot.data()["visceralFat"],
        muscle = snapshot.data()["muscle"],
        waist = snapshot.data()["waist"],
        glucose = snapshot.data()["glucose"],
        cholesterol = snapshot.data()["cholesterol"],
        hdl = snapshot.data()["hdl"],
        ldl = snapshot.data()["ldl"],
        triglycerides = snapshot.data()["triglycerides"],
        creatinine = snapshot.data()["creatinine"],
        eGFR = snapshot.data()["eGFR"],
        hba1c = snapshot.data()["hba1c"],
        uricAcid = snapshot.data()["uricAcid"],
        alt = snapshot.data()["alt_sgpt"],
        alp = snapshot.data()["alp"],
        ast = snapshot.data()["ast_sgot"];

  String toStringData(String collection) {
    switch (collection) {
      case 'pressure':
        return "ความดันบน:${pressureUpper ?? '-'}  ล่าง:${pressureLower ?? '-'} หัวใจ:${hr ?? '-'}";
        break;
      case 'weight':
        return "น้ำหนัก:${weight ?? '-'} ";
        break;
      case 'fat':
        return "bodyAge:${bodyAge ?? '-'} ไขมัน แขนขวา:${rightArmFat ?? '-'}" +
            " แขนซ้าย:${leftArmFat ?? '-'} ขาขวา:${rightLegFat ?? '-'}" +
            " ขาซ้าย:${leftLegFat ?? '-'} ลำตัว:${trunkFat ?? '-'} ";
        break;
      case 'bloodtests':
        return "น้ำตาล:${glucose ?? '-'}  คอเลสเตอรอล:${cholesterol ?? '-'} HDL:${hdl ?? '-'}" +
            " LDL:${ldl ?? '-'} Triglycerides:${triglycerides ?? '-'} Creatinine:${creatinine ?? '-'} " +
            " eGFR:${eGFR ?? '-'} UricAcid:${uricAcid ?? '-'}";
        break;
      default:
        return '';
    }
  }

  String toString() {
    String temp = '';
    snapshot.data().forEach((key, value) {
      if (key == 'kioskLocation') key = 'Kiosk';

      if (key != 'date' &&
          value != null &&
          key != 'kioskDocumentId' &&
          key != 'category') {
        temp = temp + "$key:$value ";
      }
    });
    return temp;
  }
}

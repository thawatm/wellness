import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HealthMonitor {
  DateTime date;
  String dateString;
  int pressureUpper;
  int pressureLower;
  int hr;
  double weight;
  double bmi;
  double rightArmFat;
  double leftArmFat;
  double rightLegFat;
  double leftLegFat;
  double trunkFat;
  double bodyFat;
  double visceralFat;
  double hba1c;
  int bodyAge;
  int glucose;
  int cholesterol;
  int hdl;
  int ldl;
  int triglycerides;
  double creatinine;
  double eGFR;
  double uricAcid;

  final DocumentReference reference;

  HealthMonitor.fromSnapshot(DocumentSnapshot snapshot)
      : reference = snapshot.reference,
        date = snapshot.data['date'].toDate(),
        dateString =
            DateFormat('dd/MM/yyyy').format(snapshot.data['date'].toDate()),
        pressureUpper = snapshot.data["pressureUpper"],
        pressureLower = snapshot.data["pressureLower"],
        hr = snapshot.data["hr"],
        weight = snapshot.data["weight"],
        bmi = snapshot.data["bmi"],
        rightArmFat = snapshot.data["rightArmFat"],
        leftArmFat = snapshot.data["leftArmFat"],
        rightLegFat = snapshot.data["rightLegFat"],
        leftLegFat = snapshot.data["leftLegFat"],
        trunkFat = snapshot.data["trunkFat"],
        bodyAge = snapshot.data["bodyAge"],
        bodyFat = snapshot.data["bodyFat"],
        visceralFat = snapshot.data["visceralFat"],
        glucose = snapshot.data["glucose"],
        cholesterol = snapshot.data["cholesterol"],
        hdl = snapshot.data["hdl"],
        ldl = snapshot.data["ldl"],
        triglycerides = snapshot.data["triglycerides"],
        creatinine = snapshot.data["creatinine"],
        eGFR = snapshot.data["eGFR"],
        hba1c = snapshot.data["hba1c"],
        uricAcid = snapshot.data["uricAcid"];

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
}

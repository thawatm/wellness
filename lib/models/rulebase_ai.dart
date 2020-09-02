import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wellness/dashboard/app_theme.dart';

class RuleBaseAI {
  DisplayValue display = DisplayValue();
  int neglect = 0;
  int heaven = 0;
  int weight = 0;
  String suggestion = '';

  RuleBaseAI();

  RuleBaseAI.bmi(num bmi) {
    if (bmi > 18.5 && bmi < 23) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else if (bmi >= 23) {
      display.desc = 'น้ำหนักเกิน';
      // display.color = AppTheme.kDeathColor;
      neglect = 2;
      weight = 309;
      suggestion = 'BMI มากกว่าเกณฑ์มาตรฐาน ควรออกกำลังกายอย่างสม่ำเสมอ';
      if (bmi >= 23 && bmi < 25) {
        display.color = Colors.orange;
      } else if (bmi >= 25 && bmi < 30) {
        display.color = Colors.orange.shade700;
      } else {
        display.color = AppTheme.kDeathColor;
      }
    } else {
      display.desc = 'ผอม';
      display.color = AppTheme.kDeathColor;
      neglect = 2;
      weight = 308;
      suggestion =
          'BMI น้อยกว่าเกณฑ์มาตรฐาน ควรเพิ่มน้ำหนักอีกเล็กน้อย และดูแลสุขภาพอย่างสม่ำเสมอ';
    }

    if (bmi == 0) display.color = AppTheme.grey.withOpacity(0.2);
  }

  RuleBaseAI.bloodPressure(num bpupper, num bplower) {
    if (bpupper < 130 && bplower < 80) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else {
      display.desc = 'ความดันสูง';
      display.color = AppTheme.kDeathColor;
      heaven = 2;
      weight = 209;
      suggestion =
          'ความดันยังสูงกว่าเกณฑ์มาตรฐาน หมั่นดูแลสุขภาพให้ดี และพบแพทย์เพื่อตรวจอีกครั้ง';
    }

    if (bpupper == 0 || bplower == 0)
      display.color = AppTheme.grey.withOpacity(0.2);
  }

  RuleBaseAI.ldl(num ldl) {
    if (ldl < 130) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else {
      display.desc = 'ไขมันเกิน';
      display.color = AppTheme.kDeathColor;
      heaven = 1;
      weight = 208;
      suggestion =
          'LDL ยังสูงกว่าเกณฑ์มาตรฐาน หมั่นดูแลสุขภาพให้ดี และพบแพทย์เพื่อตรวจอีกครั้ง';
    }
    if (ldl == 0) display.color = AppTheme.grey.withOpacity(0.2);
  }
  RuleBaseAI.cholesterol(num cholesterol) {
    if (cholesterol < 200) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else {
      display.desc = 'ไขมันเกิน';
      display.color = AppTheme.kDeathColor;
      heaven = 1;
    }
    if (cholesterol == 0) display.color = AppTheme.grey.withOpacity(0.2);
  }

  RuleBaseAI.glucose(num glucose) {
    if (glucose < 100) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else {
      display.desc = 'น้ำตาลเกิน';
      display.color = AppTheme.kDeathColor;
      heaven = 1;
      weight = 207;
      suggestion =
          'น้ำตาลยังสูงกว่าเกณฑ์มาตรฐาน หมั่นดูแลสุขภาพให้ดี และพบแพทย์เพื่อตรวจอีกครั้ง';
    }
    if (glucose == 0) display.color = AppTheme.grey.withOpacity(0.2);
  }
  RuleBaseAI.hba1c(num hba1c) {
    if (hba1c < 190) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else {
      display.desc = 'น้ำตาลเกิน';
      display.color = AppTheme.kDeathColor;
      heaven = 1;
      weight = 207;
      suggestion =
          'น้ำตาลยังสูงกว่าเกณฑ์มาตรฐาน หมั่นดูแลสุขภาพให้ดี และพบแพทย์เพื่อตรวจอีกครั้ง';
    }
    if (hba1c == 0) display.color = AppTheme.grey.withOpacity(0.2);
  }
  RuleBaseAI.workout(num workout, {num lastweek: 0}) {
    if (workout > 150) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else {
      display.desc = 'น้อย';
      display.color = AppTheme.kDeathColor;
      neglect = 2;
    }
    if (workout == 0) display.color = AppTheme.grey.withOpacity(0.2);
    if (workout > lastweek) {
      weight = 259;
      suggestion = 'การออกกำลังกายเพิ่มขึ้นจากสัปดาห์ที่แล้ว';
    }
    if (workout < lastweek) {
      weight = 359;
      suggestion =
          'การออกกำลังกายน้อยลงกว่าสัปดาห์ที่แล้ว พยายามออกกำลังกายให้มากขึ้น';
    }
  }
  RuleBaseAI.food(num food, {num lastweek: 0}) {
    if (food > 5) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else {
      display.desc = 'น้อย';
      display.color = AppTheme.kDeathColor;
      neglect = 2;
    }
    if (food == 0) display.color = AppTheme.grey.withOpacity(0.2);
    if (food > lastweek) {
      weight = 258;
      suggestion = 'มีการทานผักผลไม้มากขึ้นกว่าสัปดาห์ที่แล้ว';
    }
    if (food < lastweek) {
      weight = 358;
      suggestion = 'ทานผักผลไม้น้อยลงกว่าสัปดาห์ที่แล้ว พยายามทานให้มากขึ้น';
    }
  }
  RuleBaseAI.smoke(bool smoke) {
    if (smoke) {
      display.desc = 'สูบ';
      display.color = AppTheme.kDeathColor;
      heaven = 2;
      neglect = 2;
      weight = 409;
      suggestion = 'ควรเลิกสูบบุหรี่เพื่อสุขภาพที่ดีขึ้นในระยะยาว';
    } else {
      display.desc = 'ไม่สูบ';
      display.color = AppTheme.kRecovercolor;
    }
  }
  RuleBaseAI.fat(num fat) {
    if (fat == 0)
      display.color = AppTheme.grey.withOpacity(0.2);
    else
      display.color = AppTheme.nearlyDarkBlue;
  }

  String getWeeklRules(List<RuleBaseAI> list) {
    int heaven = list.fold(
        0, (previousValue, element) => previousValue + element.heaven);
    int neglect = list.fold(
        0, (previousValue, element) => previousValue + element.neglect);

    String str1 = '';
    String str2 = '';
    String str3 = '';

    if (heaven >= 6) str1 = "ควรหมั่นดูและสุขภาพและพบแพทย์อย่างสม่ำเสมอ";
    if (heaven >= 3 && neglect > 2)
      str1 =
          "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ใช้ได้ ควรหมั่นดูแลสุขภาพอย่างสม่ำเสมอ";
    if (heaven >= 3 && neglect <= 2)
      str1 = "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ใช้ได้";
    if (heaven > 0 && neglect > 2)
      str1 = "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ดี ควรหมั่นดูแลสุขภาพอย่างสม่ำเสมอ";
    if (heaven > 0 && neglect <= 2) str1 = "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ดี";
    if (neglect > 2)
      str1 =
          "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ดีมาก อย่างไรก็ตามควรหมั่นดูแลสุขภาพอย่างสม่ำเสมอ";
    if (neglect <= 2) str1 = "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ดีมาก";

    str1 = 'เพื่อสุขภาพที่แข็งแรง ควรออกกำลังกาย กินผักและผลไม้อย่างสม่ำเสมอ';

    int index2 = randomWeight(list);
    if (index2 > -1) {
      str2 = '\n• ' + list[index2].suggestion;
      list.removeAt(index2);
      int index3 = randomWeight(list);
      if (index3 > -1) str3 = '\n• ' + list[index3].suggestion;
    }

    return '• ' + str1 + str2 + str3;
  }

  int randomWeight(List<RuleBaseAI> list) {
    int sumOfWeight = 0;
    int numChoices = list.length;
    for (int i = 0; i < numChoices; i++) {
      sumOfWeight += list[i].weight;
    }
    if (sumOfWeight == 0) return -1;
    Random random = new Random();
    int rnd = random.nextInt(sumOfWeight);
    for (int i = 0; i < numChoices; i++) {
      if (rnd < list[i].weight) return i;
      rnd -= list[i].weight;
    }
    return -1;
  }
}

class DisplayValue {
  String desc;
  Color color;

  DisplayValue({
    this.desc,
    this.color,
  });
}

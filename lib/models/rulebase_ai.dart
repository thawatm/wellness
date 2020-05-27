import 'package:flutter/material.dart';
import 'package:wellness/dashboard/app_theme.dart';

class RuleBaseAI {
  DisplayValue display = DisplayValue();
  int neglect = 0;
  int heaven = 0;

  RuleBaseAI.bmi(num bmi) {
    if (bmi > 18.5 && bmi < 25) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else if (bmi >= 25) {
      display.desc = 'น้ำหนักเกิน';
      display.color = AppTheme.kDeathColor;
      neglect = 2;
    } else {
      display.desc = 'ผอม';
      display.color = AppTheme.kDeathColor;
      neglect = 2;
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
    }
    if (ldl == 0) display.color = AppTheme.grey.withOpacity(0.2);
  }
  RuleBaseAI.cholesterol(num cholesterol) {
    if (cholesterol < 190) {
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
    }
    if (hba1c == 0) display.color = AppTheme.grey.withOpacity(0.2);
  }
  RuleBaseAI.workout(num workout) {
    if (workout > 150) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else {
      display.desc = 'น้อย';
      display.color = AppTheme.kDeathColor;
      neglect = 2;
    }
    if (workout == 0) display.color = AppTheme.grey.withOpacity(0.2);
  }
  RuleBaseAI.food(num food) {
    if (food > 5) {
      display.desc = 'ปกติ';
      display.color = AppTheme.kRecovercolor;
    } else {
      display.desc = 'น้อย';
      display.color = AppTheme.kDeathColor;
      neglect = 2;
    }
    if (food == 0) display.color = AppTheme.grey.withOpacity(0.2);
  }
  RuleBaseAI.smoke(bool smoke) {
    if (smoke) {
      display.desc = 'สูบ';
      display.color = AppTheme.kDeathColor;
      heaven = 2;
      neglect = 2;
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

    if (heaven >= 6) return "ควรหมั่นดูและสุขภาพและพบแพทย์อย่างสม่ำเสมอ";
    if (heaven >= 3 && neglect > 2)
      return "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ใช้ได้ ควรหมั่นดูแลสุขภาพอย่างสม่ำเสมอ";
    if (heaven >= 3 && neglect <= 2)
      return "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ใช้ได้";
    if (heaven > 0 && neglect > 2)
      return "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ดี ควรหมั่นดูแลสุขภาพอย่างสม่ำเสมอ";
    if (heaven > 0 && neglect <= 2) return "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ดี";
    if (neglect > 2)
      return "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ดีมาก อย่างไรก็ตามควรหมั่นดูแลสุขภาพอย่างสม่ำเสมอ";
    if (neglect <= 2) return "สุขภาพโดยรวมของท่านอยู่ในเกณฑ์ดีมาก";

    return 'เพื่อสุขภาพที่แข็งแรง ควรออกกำลังกาย กินผักและผลไม้อย่างสม่ำเสมอ';
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

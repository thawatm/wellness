import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';

class KioskInfoPage extends StatelessWidget {
  final String bunDescription = '''
ค่า BUN (Blood Urea Nitrogen) ปกติมักจะมีค่าไม่เกิน 20 mg/dL หากค่าไม่อยู่ในช่วงนี้อาจเกิดจากยาบางชนิด สำหรับค่าที่สูงผิดปกติสามารถเกิดได้จากหลายสาเหตุ เช่น ภาวะขาดน้ำ การรับประทานอาหารโปรตีนในขนาดสูง หรืออาจเกิดจากการทำงานของไตลดลง ควรปรึกษาแพทย์เพิ่มเติมเพื่อวินิจฉัยสาเหตุที่ทำให้ค่าผิดไปจากปกติ
''';

  final String kioskDescription = '''
  • ธนาคารเพื่อการเกษตรและสหกรณ์การเกษตร (ธ.ก.ส.) 
  • สำนักงานหลักประกันสุขภาพแห่งชาติ (สปสช.)
  • สำนักงานพัฒนาวิทยาศาสตร์และเทคโนโลยีแห่งชาติ (สวทช.)
''';

  final String kioskPropose = '''
พัฒนาเครื่องวัดสุขภาพเบื้องต้นอัตโนมัติเพื่อติดตั้งที่ ธ.ก.ส. ประมาณ 100 สาขา ทั่วประเทศ ในช่วงไตรมาสแรกของปี 2563
''';
  final TextStyle paragraph = TextStyle(
    fontSize: 16,
    fontFamily: 'Prompt',
    color: Colors.grey[800],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          title: Text('NSTDA Kiosk'),
          gradient: LinearGradient(
              colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 15),
                child: Text('เครื่องวัดสุขภาพเบื้องต้นอัตโนมัติ',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            SizedBox(height: 20),
            Container(
              height: 250,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  image: DecorationImage(
                    image: AssetImage('assets/images/kiosk.png'),
                    fit: BoxFit.fitHeight,
                  )),
            ),
            SizedBox(height: 30),
            Container(
                padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                child: Text('วัตถุประสงค์',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Container(
              padding: EdgeInsets.fromLTRB(15, 6, 10, 0),
              child: Text(
                kioskPropose,
                style: paragraph,
              ),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                child: Text('โดยเป็นโครงการวิจัยร่วมระหว่าง 3 ฝ่าย คือ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Container(
              padding: EdgeInsets.fromLTRB(15, 6, 10, 0),
              child: Text(
                kioskDescription,
                style: paragraph,
              ),
            ),
          ],
        ));
  }
}

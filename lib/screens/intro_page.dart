import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

const img1 = "assets/images/logo.png";
const img3 = "assets/images/simple7.png";
const img4 = "assets/images/dialysis_kidney.png";

class IntroPage extends StatelessWidget {
  const IntroPage({Key key}) : super(key: key);

  void _onIntroEnd(context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildImage(String image) {
    return Align(
      child: Image.asset(image, height: 200.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "โปรแกรมสุขภาพดีวัยทำงาน",
            body:
                "โดยศูนย์วิจัยเทคโนโลยีสิ่งอำนวยความสะดวกและเครื่องมือแพทย์ ร่วมกับเครือข่ายศูนย์สุขภาพดีวัยทำงาน และเวลเนส วีแคร์ เซ็นเตอร์ โดย นพ.สันต์ ใจยอดศิลป์",
            image: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/amedlogo.png', height: 140),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/icon.png', height: 80),
                    Image.asset('assets/images/wecare_logo.png', height: 100),
                  ],
                ),
                SizedBox(height: 20)
              ],
            ),
          ),
          PageViewModel(
            title: "Life’s Simple 7",
            body:
                "“ทุกคนมีสุขภาพดีได้ด้วยตัวชี้วัด 7 อย่าง”\n\nสมาคมโรคหัวใจสหรัฐอเมริกา ได้กำหนดนิยามของสุขภาพหัวใจและหลอดเลือดที่ดี โดยกำหนดเป็นตัวชี้วัดง่าย ๆ รวม 7 อย่าง เพื่อให้ผู้คนสามารถมีสุขภาพดีได้ผ่านการปรับเปลี่ยนพฤติกรรมและวิถีชีวิตที่เหมาะสม",
            image: Align(
              child: Image.asset(img3, height: 280.0),
              alignment: Alignment.bottomCenter,
            ),
          ),
          PageViewModel(
            title: "การปรับเปลี่ยนพฤติกรรมและติดตามผล",
            body:
                "การปรับเปลี่ยนพฤติกรรมและวิถีชีวิตที่เหมาะสม โดยการปฏิบัติตามตัวชี้วัด 7 อย่าง ได้รับการพิสูจน์แล้วว่าสามารถช่วยลดความเสี่ยงในการเสียชีวิตจากโรคหัวใจได้ โดยโปรแกรมของเราจะช่วยประเมินและให้คำแนะนำส่วนตัวรายสัปดาห์ รวมทั้งเก็บข้อมูลเพื่อใช้เฝ้าติดตามสุขภาพของท่านต่อไป",
            image: _buildImage(img4),
          )
        ],
        onDone: () => _onIntroEnd(context),
        //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,
        skipFlex: 0,
        nextFlex: 0,
        skip: const Text('Skip'),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(30.0, 16.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }
}

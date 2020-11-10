import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

const img1 = "assets/images/logo.png";
const img3 = "assets/images/simple7.png";
const img4 = "assets/images/dialysis_kidney.png";

class KnowledgeSimple7Page extends StatelessWidget {
  const KnowledgeSimple7Page({Key key}) : super(key: key);

  void _onIntroEnd(context) {
    Navigator.pop(context);
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
          // PageViewModel(
          //   title: "โปรแกรมไทยสุข",
          //   body:
          //       "โดยศูนย์วิจัยเทคโนโลยีสิ่งอำนวยความสะดวกและเครื่องมือแพทย์ ร่วมกับเครือข่ายศูนย์สุขภาพดีวัยทำงาน และเวลเนส วีแคร์ เซ็นเตอร์ โดย นพ.สันต์ ใจยอดศิลป์",
          //   image: Column(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     mainAxisSize: MainAxisSize.max,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: <Widget>[
          //       Image.asset('assets/images/amedlogo.png', height: 140),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: <Widget>[
          //           Image.asset('assets/images/icon.png', height: 80),
          //           Image.asset('assets/images/wecare_logo.png', height: 100),
          //         ],
          //       ),
          //       SizedBox(height: 20)
          //     ],
          //   ),
          // ),
          PageViewModel(
            title: "Life’s Simple 7",
            body:
                "“ทุกคนมีสุขภาพดีได้ด้วยตัวชี้วัด 7 อย่าง”\nงานวิจัยที่ได้รับการรับรองโดยสมาคมโรคหัวใจสหรัฐอเมริกา พบว่าการปรับเปลี่ยนพฤติกรรมและวิถีชีวิตที่เหมาะสมโดยการปฏิบัติตามตัวชี้วัดง่าย ๆ รวม 7 อย่าง สามารถลดความเสี่ยงในการเสียชีวิตก่อนวัยอันควรได้ถึงร้อยละ 91",
            image: Align(
              child: Image.asset(img3, height: 280.0),
              alignment: Alignment.bottomCenter,
            ),
          ),
          PageViewModel(
            title: "การปรับเปลี่ยนพฤติกรรมและติดตามผล",
            body:
                "โปรแกรมของเราช่วยให้สามารถติดตามดัชนีทั้ง 7 อย่าง คือ ปริมาณการออกกำลังกาย ปริมาณการบริโภคผักผลไม้ ดัชนีมวลกาย การสูบบุหรี่ ความดันโลหิต ค่าไขมันในเลือด และค่าน้ำตาลในเลือด ได้อย่างง่ายดาย และช่วยประเมินพร้อมให้คำแนะนำรายสัปดาห์ เป็นผู้ช่วยส่วนตัวในการเฝ้าติดตามสุขภาพของท่านต่อไป",
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

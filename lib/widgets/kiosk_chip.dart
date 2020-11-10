import 'package:flutter/material.dart';
import 'package:wellness/widgets/webview.dart';

class KioskChip extends StatelessWidget {
  final String kioskDocumentId;
  const KioskChip({Key key, this.kioskDocumentId});
  @override
  Widget build(BuildContext context) {
    return InputChip(
      // avatar: CircleAvatar(
      //   backgroundColor: Colors.cyan.shade600,
      //   child: Text('K'),
      // ),
      label: Text('NSTDA Kiosk',
          style: TextStyle(color: Colors.white, fontSize: 14)),
      backgroundColor: Colors.cyan.shade300,
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CustomWebView(
                    url: 'http://bsp-kiosk.ddns.net/?id=' + kioskDocumentId)));
      },
    );
  }
}

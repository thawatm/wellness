import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellness/models/state_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:easy_alert/easy_alert.dart';

class MedicalMemoPage extends StatefulWidget {
  @override
  _MedicalMemoPageState createState() => _MedicalMemoPageState();
}

class _MedicalMemoPageState extends State<MedicalMemoPage> {
  String uid;
  List<DocumentSnapshot> snapshotData;

  @override
  void initState() {
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text('ข้อมูลอื่น ๆ'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.appBarColor2,
        onPressed: () => Navigator.pushNamed(context, '/medical_memo_add'),
        tooltip: 'Add Memo',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wellness_data')
            .doc(uid)
            .collection('medical_note')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LoadingIndicator();
          snapshotData = snapshot.data.docs
            ..sort((a, b) =>
                b.data()['date'].toDate().compareTo(a.data()['date'].toDate()));
          return snapshotData.isEmpty
              ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่ไอคอนมุมขวาล่าง")
              : _buildList(context, snapshotData);
        });
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshotData) {
    return ListView.builder(
      itemCount: snapshotData.length,
      itemBuilder: (context, i) {
        return InkWell(
          onTap: () async {
            final url = snapshotData[i].data()['imageUrl'];

            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          onLongPress: () => Alert.confirm(context,
                  title: "Delete Note", content: 'ต้องการลบข้อมูลนี้?')
              .then((int ret) {
            if (ret == Alert.OK) {
              _deleteData(snapshotData[i]);
            } else {
              return;
            }
          }),
          child: Card(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            elevation: 2,
            child: Column(
              children: <Widget>[
                snapshotData[i].data()['imageUrl'] != null
                    ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            // alignment: Alignment(0, 0),
                            fit: BoxFit.cover,
                            //  add image URL
                            image: NetworkImage(
                                snapshotData[i].data()['imageUrl']),
                          ),
                        ),
                      )
                    : SizedBox(),
                snapshotData[i].data()['note'] == null
                    ? SizedBox()
                    : Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        //  add message
                        child: Text(
                          snapshotData[i].data()['note'],
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade800),
                        )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: AppTheme.grey.withOpacity(0.6),
                        size: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          _convertDate(snapshotData[i].data()['date'].toDate()),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            letterSpacing: 0.0,
                            color: AppTheme.grey.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  String _convertDate(DateTime date) {
    // DateTime date = DateTime.parse(src);
    return DateFormat.yMMMd().format(date);
  }

  _deleteData(DocumentSnapshot snapshot) {
    String uploadPath = snapshot.data()['uploadPath'];
    String id = snapshot.id;
    final FirebaseStorage storage =
        FirebaseStorage(storageBucket: 'gs://bsp-kiosk.appspot.com');
    if (uploadPath != null) storage.ref().child(uploadPath).delete();
    FirebaseFirestore.instance
        .collection('wellness_data')
        .doc(uid)
        .collection('medical_note')
        .doc(id)
        .delete()
        .catchError((e) {
      print(e);
    });
  }
}

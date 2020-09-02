import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:intl/intl.dart';
import 'package:wellness/widgets/kiosk_chip.dart';

class HistoryList extends StatelessWidget {
  const HistoryList(
      {Key key,
      @required this.snapshot,
      @required this.collection,
      @required this.uid,
      this.kioskDocumentId})
      : assert(snapshot != null),
        assert(collection != null),
        assert(uid != null),
        super(key: key);

  final List<DocumentSnapshot> snapshot;
  final String uid;
  final String collection;
  final String kioskDocumentId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) {
        if (data['category'] == collection) {
          return _buildListItem(context, data);
        } else if (collection == 'weight' ||
            collection == 'pressure' ||
            collection == 'workout') {
          return _buildListItem(context, data);
        } else {
          return SizedBox();
        }
      }).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    var record = HealthMonitor.fromSnapshot(data);
    Text subtitle = Text(record.toString());

    if (data['kioskDocumentId'] != null) {
      subtitle = Text(
        record.toString(),
        style: TextStyle(color: Colors.teal),
      );
    }

    return Column(
      children: <Widget>[
        ListTile(
          title: Row(children: <Widget>[
            Text(DateFormat.yMMMd().format(record.date),
                style: TextStyle(color: Colors.black87)),
            SizedBox(width: 10),
            (data['kioskDocumentId'] != null)
                ? KioskChip(
                    kioskDocumentId: data['kioskDocumentId'],
                  )
                : SizedBox(width: 0),
          ]),
          subtitle: subtitle,
          onTap: () {
            Alert.confirm(
              context,
              title: "ลบข้อมูล",
              content: DateFormat('dd/MM/yyyy').format(record.date),
            ).then((int ret) => ret == Alert.OK
                ? deleteData(data.documentID, data['kioskDocumentId'])
                : null);
          },
        ),
        Divider(
          height: 2.0,
        ),
      ],
    );
  }

  deleteData(docId, kioskDocumentId) {
    String col = collection;
    if (collection != 'workout') col = 'healthdata';
    Firestore.instance
        .collection('wellness_data')
        .document(uid)
        .collection(col)
        .document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });

    if (kioskDocumentId != null) {
      Firestore.instance
          .collection('data')
          .document(kioskDocumentId)
          .delete()
          .catchError((e) {
        print(e);
      });
    }
  }
}

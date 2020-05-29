import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:intl/intl.dart';

enum ConfirmAction { CANCEL, DELETE }

class HistoryList extends StatelessWidget {
  const HistoryList(
      {Key key,
      @required this.snapshot,
      @required this.collection,
      @required this.uid})
      : assert(snapshot != null),
        assert(collection != null),
        assert(uid != null),
        super(key: key);

  final List<DocumentSnapshot> snapshot;
  final String uid;
  final String collection;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    var record;
    switch (collection) {
      case 'pressure':
        record = HealthMonitor.fromSnapshot(data);
        break;
      default:
        record = HealthMonitor.fromSnapshot(data);
    }

    return Column(
      children: <Widget>[
        ListTile(
          title: Text(DateFormat.yMMMEd().format(record.date)),
          subtitle: Text(record.toString()),
          onTap: () {
            Alert.confirm(
              context,
              title: "ลบข้อมูล",
              content: DateFormat('dd/MM/yyyy').format(record.date),
            ).then((int ret) =>
                ret == Alert.OK ? deleteData(data.documentID) : null);
          },
        ),
        Divider(
          height: 2.0,
        ),
      ],
    );
  }

  deleteData(docId) {
    Firestore.instance
        .collection('wellness_data')
        .document(uid)
        .collection('healthdata')
        .document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<ConfirmAction> confirmDialog(
      BuildContext context, HealthMonitor record) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ลบข้อมูล"),
          content: Text(
            DateFormat('dd/MM/yyyy').format(record.date),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('DELETE'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.DELETE);
              },
            )
          ],
        );
      },
    );
  }
}

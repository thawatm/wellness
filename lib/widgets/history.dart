import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

enum ConfirmAction { CANCEL, DELETE }

class HistoryList extends StatelessWidget {
  const HistoryList(
      {Key key,
      @required this.snapshot,
      @required this.collection,
      @required this.currentUser})
      : assert(snapshot != null),
        assert(collection != null),
        assert(currentUser != null),
        super(key: key);

  final List<DocumentSnapshot> snapshot;
  final FirebaseUser currentUser;
  final String collection;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = HealthMonitor.fromSnapshot(data);

    return Column(
      children: <Widget>[
        ListTile(
          title: Text(DateFormat.yMMMEd().format(record.date)),
          subtitle: Text(record.toStringData(collection)),
          onTap: () {
            // final ConfirmAction action = await confirmDialog(context, record);
            // if (action.toString() == 'ConfirmAction.DELETE') {
            //   deleteData(data.documentID);
            // }

            Alert(
              context: context,
              type: AlertType.warning,
              title: "ลบข้อมูล",
              desc: DateFormat('dd/MM/yyyy').format(record.date),
              buttons: [
                DialogButton(
                  child: Text(
                    "ยกเลิก",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.green,
                ),
                DialogButton(
                  child: Text(
                    "ลบ",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () {
                    deleteData(data.documentID);
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                )
              ],
            ).show();
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
        .collection('monitor')
        .document(currentUser.uid)
        .collection(collection)
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

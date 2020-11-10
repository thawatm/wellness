import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';

class GroupAdminPage extends StatefulWidget {
  const GroupAdminPage({Key key, @required this.groupId}) : super(key: key);
  final String groupId;
  @override
  _GroupAdminPageState createState() => _GroupAdminPageState();
}

class _GroupAdminPageState extends State<GroupAdminPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  String resultText = '';
  String uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
            title: Text('เพิ่มผู้ดูแล'),
            gradient: LinearGradient(
                colors: [AppTheme.appBarColor1, AppTheme.appBarColor2])),
        body: buildBody());
  }

  Widget buildBody() {
    return FormBuilder(
      key: _fbKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 16),
            FormBuilderTextField(
              attribute: 'phoneNumber',
              cursorColor: Colors.black,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
                labelText: 'ค้นหาจากเบอร์มือถือ',
              ),
              onChanged: (tel) => _search(tel),
              validators: [
                FormBuilderValidators.required(
                    errorText: 'This field required'),
                FormBuilderValidators.numeric()
              ],
            ),
            SizedBox(height: 12),
            _searchResult()
          ],
        ),
      ),
    );
  }

  Widget _searchResult() {
    if (resultText == '') return SizedBox();
    if (resultText == 'ไม่มีข้อมูล') return Text('ไม่มีข้อมูล');
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(resultText),
      trailing: IconButton(icon: Icon(Icons.add), onPressed: null),
      onTap: () {
        _addAdmin();
      },
    );
  }

  _search(String phoneNumber) {
    if (phoneNumber.length < 10) {
      setState(() {
        resultText = '';
      });
      return;
    }
    String tel = '+66' + phoneNumber.substring(1);

    FirebaseFirestore.instance
        .collection('wellness_users')
        .where('phoneNumber', isEqualTo: tel)
        .get()
        .then((v) {
      String r, id;
      if (v.docs.isEmpty) {
        r = 'ไม่มีข้อมูล';
      } else {
        r = v.docs.first.data()['firstname'] +
            ' ' +
            v.docs.first.data()['lastname'];
        id = v.docs.first.id;
      }
      setState(() {
        resultText = r;
        uid = id;
      });
    });
  }

  _addAdmin() async {
    Map<String, dynamic> groupData = {'admin': true};
    try {
      await FirebaseFirestore.instance
          .doc('wellness_groups/${widget.groupId}/members/$uid')
          .update(groupData);
      await FirebaseFirestore.instance
          .doc('wellness_users/$uid/groups/${widget.groupId}')
          .update(groupData);
      Navigator.pop(context);
    } catch (e) {
      try {
        await FirebaseFirestore.instance
            .doc('wellness_groups/${widget.groupId}/members/$uid')
            .set(groupData);
        await FirebaseFirestore.instance
            .doc('wellness_users/$uid/groups/${widget.groupId}')
            .set(groupData);
        Navigator.pop(context);
      } catch (e1) {
        print(e1);
      }
    }
  }
}

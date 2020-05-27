import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:scoped_model/scoped_model.dart';

class GroupAddPage extends StatefulWidget {
  const GroupAddPage({Key key}) : super(key: key);
  @override
  _GroupAddPageState createState() => _GroupAddPageState();
}

class _GroupAddPageState extends State<GroupAddPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  String uid;
  bool _autovalidate = false;
  bool _isLoading = false;

  @override
  void initState() {
    uid = ScopedModel.of<StateModel>(context).uid;
    super.initState();
  }

  void _handleSubmitted() async {
    if (_fbKey.currentState.saveAndValidate()) {
      setState(() {
        _isLoading = true;
      });

      String groupId = '1000';

      var groupData = _fbKey.currentState.value;
      groupData['owner'] = uid;

      await Firestore.instance
          .collection('wellness_groups')
          .getDocuments()
          .then((docs) {
        groupId = docs.documents?.last?.documentID;
        if (groupId != null) {
          groupId = (int.parse(groupId) + 1).toString();
        }
      }).catchError((e) {});

      Firestore.instance
          .document('wellness_groups/$groupId')
          .setData(groupData);

      showInSnackBar("Successful");
      ScopedModel.of<StateModel>(context).isLoading = true;
      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    } else {
      // print(_fbKey.currentState.value);

      print("validation failed");
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerDragStartBehavior: DragStartBehavior.down,
      key: _scaffoldKey,
      appBar: GradientAppBar(
        title: Text('สร้างกลุ่มใหม่'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body: ModalProgressHUD(child: _formView(), inAsyncCall: _isLoading),
    );
  }

  Widget _formView() {
    return SafeArea(
      top: false,
      bottom: false,
      child: FormBuilder(
        key: _fbKey,
        autovalidate: _autovalidate,
        child: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 30.0),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
                  child: FormBuilderTextField(
                    maxLines: 1,
                    attribute: 'name',
                    decoration: InputDecoration(
                      labelText: 'ชื่อกลุ่ม',
                      contentPadding: EdgeInsets.only(top: 10.0, bottom: 4),
                    ),
                    style: TextStyle(fontSize: 18),
                    // onChanged: _onChanged,
                    validators: [
                      FormBuilderValidators.required(errorText: 'ใส่ชื่อกลุ่ม'),
                      FormBuilderValidators.max(50),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: Container(
                    height: 50,
                    width: 200,
                    child: RaisedButton.icon(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _handleSubmitted();
                      },
                      elevation: 7.0,
                      color: AppTheme.buttonColor,
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text('ยืนยัน',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

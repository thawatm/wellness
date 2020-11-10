import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:scoped_model/scoped_model.dart';

class GroupEditPage extends StatefulWidget {
  const GroupEditPage({Key key, this.groupId}) : super(key: key);
  final String groupId;
  @override
  _GroupEditPageState createState() => _GroupEditPageState();
}

class _GroupEditPageState extends State<GroupEditPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  String uid;
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

      var groupData = _fbKey.currentState.value;

      String groupId = widget.groupId;
      FirebaseFirestore.instance
          .doc('wellness_groups/$groupId')
          .update(groupData);

      showInSnackBar("Successful");
      ScopedModel.of<StateModel>(context).isLoading = true;
      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
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
        title: Text('แก้ไขกลุ่ม'),
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
        autovalidateMode: AutovalidateMode.always,
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

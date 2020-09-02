import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/dashboard/ui_view/title_view.dart';
import 'package:wellness/group/group_admin.dart';
import 'package:wellness/group/group_detail_edit.dart';
import 'package:wellness/group/group_edit.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/userdata.dart';
import 'package:wellness/report/report_screen.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage(
      {Key key,
      this.animationController,
      this.isAdmin: false,
      @required this.groupId})
      : super(key: key);
  final AnimationController animationController;
  final bool isAdmin;
  final String groupId;

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ImageProvider profileImage = AssetImage('assets/images/user.png');
  Future<bool> initData; //changed
  String groupName;
  String groupDesc;
  String owner;
  bool isOwner = false;
  String uid;
  int memberCount = 0;
  @override
  void initState() {
    uid = ScopedModel.of<StateModel>(context).uid;
    super.initState();
    initData = getData();
  }

  Future<bool> getData() async {
    return await Firestore.instance
        .collection('wellness_groups')
        .document(widget.groupId)
        .get()
        .then((g) {
      groupName = g.data['name'];
      groupDesc = g.data['desc'];
      owner = g.data['owner'];
      if (uid == owner) isOwner = true;
      return true;
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();
          return Scaffold(
            drawerDragStartBehavior: DragStartBehavior.down,
            key: _scaffoldKey,
            appBar: GradientAppBar(
              title: Text('รายละเอียดกลุ่ม'),
              gradient: LinearGradient(
                  colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
              actions: <Widget>[
                IconButton(
                  onPressed: () => Alert.confirm(context,
                          title: "Leave Group", content: 'ต้องการออกจากกลุ่ม?')
                      .then((int ret) {
                    if (ret == Alert.OK) {
                      _leaveGroup(widget.groupId, uid);
                      Navigator.pop(context);
                    } else {
                      return;
                    }
                  }),
                  icon: Icon(Icons.exit_to_app),
                ),
                isOwner
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => Alert.confirm(context,
                                title: "Delete group",
                                content: 'ต้องการลบกลุ่มนี้?')
                            .then((int ret) => ret == Alert.OK
                                ? _deleteGroup(widget.groupId)
                                : null))
                    : SizedBox(width: 0),
              ],
            ),
            body: _buildBody(),
          );
        });
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('wellness_groups')
            .document(widget.groupId)
            .collection('members')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          memberCount = snapshot.data.documents.length;
          var listViews = snapshot.data.documents
              .map((v) => FutureBuilder(
                  future: _getProfileName(v.documentID),
                  builder: (context, AsyncSnapshot<UserProfile> userSn) {
                    if (!userSn.hasData) return SizedBox();
                    return ListTile(
                      leading: _buildAvatar(userSn.data.pictureUrl),
                      title: Text(userSn.data.fullname),
                      trailing: !widget.isAdmin
                          ? SizedBox()
                          : InkWell(
                              onTap: () => Alert.confirm(context,
                                      title: "Delete",
                                      content:
                                          "ต้องการลบผู้ใช้งานนี้ออกจากกลุ่ม?")
                                  .then((int ret) => ret == Alert.OK
                                      ? _leaveGroup(
                                          widget.groupId, userSn.data.uid)
                                      : null),
                              //),
                              child: Icon(Icons.delete)),
                      onTap: () {
                        if (widget.isAdmin || isOwner) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReportScreen(
                                        uid: userSn.data.uid,
                                        animationController:
                                            widget.animationController,
                                        isPop: true,
                                      )));
                        }
                      },
                    );
                  }))
              .toList();
          return ListView(
            children: <Widget>[
              SizedBox(height: 16),
              TitleView(
                titleTxt: 'กลุ่ม: ' + widget.groupId,
                isMenuOption: false,
              ),
              _buildHeader(),
              SizedBox(height: 20),
              TitleView(
                titleTxt: listViews.isNotEmpty
                    ? "สมาชิก ($memberCount)"
                    : 'ยังไม่มีสมาชิก',
                isMenuOption: false,
              ),
              _buildMemberList(listViews),
            ],
          );
        });
  }

  Widget _buildHeader() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                  topRight: Radius.circular(8.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: AppTheme.grey.withOpacity(0.2),
                    offset: Offset(1.1, 1.1),
                    blurRadius: 10.0),
              ],
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                    onTap: () {
                      if (widget.isAdmin)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  GroupEditPage(groupId: widget.groupId)),
                        );
                    },
                    leading:
                        Icon(FontAwesomeIcons.userFriends, color: Colors.teal),
                    title: Text('ชื่อกลุ่ม'),
                    subtitle: Text(groupName)),
                ListTile(
                  leading: Icon(FontAwesomeIcons.userNurse, color: Colors.teal),
                  title: Text('ผู้ดูแล'),
                  // trailing: isOwner
                  //     ? IconButton(
                  //         icon: Icon(Icons.add),
                  //         onPressed: () {
                  //           Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (_) => GroupAdminPage()));
                  //         },
                  //       )
                  //     : null,
                  subtitle: FutureBuilder<UserProfile>(
                      future: _getProfileName(owner),
                      builder: (context, AsyncSnapshot<UserProfile> sn) {
                        if (!sn.hasData) return SizedBox();
                        return Wrap(children: [
                          InputChip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Icon(
                                FontAwesomeIcons.crown,
                                size: 10,
                              ),
                            ),
                            label: Text(sn.data.fullname),
                          ),
                        ]);
                      }),
                ),
                ListTile(
                    onTap: () {
                      if (widget.isAdmin)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  GroupDetailEditPage(groupId: widget.groupId)),
                        );
                    },
                    leading:
                        Icon(FontAwesomeIcons.infoCircle, color: Colors.teal),
                    title: Text('รายละเอียด'),
                    subtitle: Text(groupDesc ?? '')),
              ],
            )));
  }

  Widget _buildMemberList(var listViews) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topRight: Radius.circular(8.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: AppTheme.grey.withOpacity(0.2),
                offset: Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
        ),
        child: Column(children: listViews),
      ),
    );
  }

  Widget _buildAvatar(String src) {
    return InkWell(
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: new Border.all(color: Colors.grey.shade300, width: 1),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: src == null ? profileImage : NetworkImage(src),
            )),
      ),
    );
  }

  Future<UserProfile> _getProfileName(String uid) {
    return Firestore.instance.document('wellness_users/$uid').get().then((v) {
      return UserProfile.fromSnapshot(v);
    });
  }

  void _leaveGroup(String groupId, String uid) {
    Firestore.instance
        .document('wellness_groups/$groupId/members/$uid')
        .delete();
    Firestore.instance.document('wellness_users/$uid/groups/$groupId').delete();
  }

  Future<void> _deleteGroup(String groupId) async {
    await Firestore.instance
        .collection('wellness_groups/$groupId/members')
        .getDocuments()
        .then((v) {
      v.documents.forEach((d) {
        String uid = d.documentID;
        Firestore.instance
            .document('wellness_users/$uid/groups/$groupId')
            .delete();
        Firestore.instance
            .document('wellness_groups/$groupId/members/$uid')
            .delete();
      });
    }).then((value) {
      Firestore.instance.document('wellness_groups/$groupId').delete();
      Navigator.pop(context);
    }).catchError((e) {
      print(e);
    });
  }
}

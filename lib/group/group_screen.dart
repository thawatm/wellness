import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/dashboard/ui_view/title_view.dart';
import 'package:wellness/group/group_detail.dart';
import 'package:wellness/models/state_model.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/widgets/appbar_ui.dart';
import 'package:wellness/widgets/first_load.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Animation<double> topBarAnimation;
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  String uid;

  ImageProvider profileImage;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: SpeedDial(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.add),
          curve: Curves.easeIn,
          children: [
            SpeedDialChild(
              child: Icon(FontAwesomeIcons.userFriends, size: 16),
              label: "เข้ากลุ่ม",
              labelStyle: TextStyle(fontSize: 16.0, color: Colors.white),
              labelBackgroundColor: Colors.blueAccent,
              backgroundColor: Colors.blueAccent,
              onTap: () => Navigator.pushNamed(context, '/groupjoin'),
            ),
            SpeedDialChild(
              child: Icon(FontAwesomeIcons.userPlus, size: 16),
              label: "สร้างกลุ่ม",
              labelStyle: TextStyle(fontSize: 16.0, color: Colors.white),
              labelBackgroundColor: Colors.blueAccent,
              backgroundColor: Colors.blueAccent,
              onTap: () => Navigator.pushNamed(context, '/groupadd'),
            ),
          ],
        ),
        body: Stack(children: <Widget>[
          _buildBody(context),
          AppBarUI(
            animationController: widget.animationController,
            topBarAnimation: topBarAnimation,
            topBarOpacity: topBarOpacity,
            title: 'กลุ่ม',
            isPop: true,
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ]),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('wellness_groups')
            .where('owner', isEqualTo: uid)
            .snapshots(),
        builder: (context, ownerSn) {
          return StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('wellness_users')
                  .document(uid)
                  .collection('groups')
                  .snapshots(),
              builder: (context, memberSn) {
                if (!(ownerSn.hasData && memberSn.hasData))
                  LinearProgressIndicator();
                bool onwerEmpty = false;
                bool memberEmpty = false;

                if (ownerSn.data != null)
                  onwerEmpty = ownerSn.data.documents.isEmpty;
                if (memberSn.data != null)
                  memberEmpty = memberSn.data.documents.isEmpty;

                return (onwerEmpty && memberEmpty)
                    ? FirstLoad(
                        title: "สร้างหรือเข้ากลุ่มใหม่\nแตะที่ไอคอนมุมขวาล่าง")
                    : ListView(
                        children: <Widget>[
                          SizedBox(height: 80),
                          _buildOwnerList(ownerSn),
                          SizedBox(height: 20),
                          _buildMemberList(memberSn)
                        ],
                      );
              });
        });
  }

  Widget _buildOwnerList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.data == null) return SizedBox();
    var ownerList = snapshot.data.documents
        .map((e) => InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupDetailPage(
                          animationController: widget.animationController,
                          groupId: e.documentID,
                          isAdmin: true,
                        )),
              ),
              child: FutureBuilder(
                  future: _getGroupName(e.documentID),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox();
                    return ListTile(
                      leading: Icon(
                        FontAwesomeIcons.userNurse,
                        color: Colors.teal,
                      ),
                      title: Text(snapshot.data),
                      subtitle: Text('เลขกลุ่ม: ' + e.documentID),
                      trailing: InkWell(
                          onTap: () => Alert.confirm(context,
                                  title: "Delete group",
                                  content: "ต้องการลบกลุ่มนี้?")
                              .then((int ret) => ret == Alert.OK
                                  ? _deleteGroup(e.documentID)
                                  : null),
                          child: Icon(Icons.delete)),
                    );
                  }),
            ))
        .toList();

    return ownerList.isEmpty
        ? SizedBox()
        : Column(children: <Widget>[
            TitleView(titleTxt: 'กลุ่มที่ท่านดูแล', isMenuOption: false),
            Padding(
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
                  children: ownerList,
                ),
              ),
            ),
          ]);
  }

  Widget _buildMemberList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.data == null) return SizedBox();
    var memberList = snapshot.data.documents
        .map((e) => InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupDetailPage(
                          animationController: widget.animationController,
                          groupId: e.documentID,
                        )),
              ),
              child: FutureBuilder(
                  future: _getGroupName(e.documentID),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox();
                    return ListTile(
                      leading: Icon(FontAwesomeIcons.userFriends,
                          color: Colors.blue),
                      title: Text(snapshot.data),
                      subtitle: Text('เลขกลุ่ม: ' + e.documentID),
                      trailing: InkWell(
                          onTap: () => Alert.confirm(context,
                                  title: "Leave Group",
                                  content: 'ต้องการออกจากกลุ่ม?')
                              .then((int ret) => ret == Alert.OK
                                  ? _leaveGroup(e.documentID, uid)
                                  : null),
                          child: Icon(Icons.exit_to_app)),
                    );
                  }),
            ))
        .toList();

    return memberList.isEmpty
        ? SizedBox()
        : Column(children: <Widget>[
            TitleView(titleTxt: 'กลุ่มที่ท่านเป็นสมาชิก', isMenuOption: false),
            Padding(
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
                  children: memberList,
                ),
              ),
            ),
          ]);
  }

  Future<String> _getGroupName(String groupId) {
    return Firestore.instance
        .document('wellness_groups/$groupId')
        .get()
        .then((v) {
      return v['name'];
    });
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
    }).catchError((e) {
      print(e);
    });
  }

  void _leaveGroup(String groupId, String uid) {
    Firestore.instance
        .document('wellness_groups/$groupId/members/$uid')
        .delete();
    Firestore.instance.document('wellness_users/$uid/groups/$groupId').delete();
  }
}

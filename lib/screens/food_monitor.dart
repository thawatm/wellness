import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/logic/constant.dart';
import 'package:wellness/models/fooddata.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/widgets/bar_chart.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:wellness/widgets/image_source.dart';
import 'package:wellness/widgets/loading_indicator.dart';
import 'package:wellness/widgets/social_date.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:image/image.dart' as ImagePackage;
import 'package:mime_type/mime_type.dart';

enum ConfirmAction { CANCEL, DELETE }

class FoodMonitorPage extends StatefulWidget {
  @override
  _FoodMonitorPageState createState() => _FoodMonitorPageState();
}

class _FoodMonitorPageState extends State<FoodMonitorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollViewController;
  File tempImage;

  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://wellness-296bf.appspot.com');
  FirebaseUser currentUser;
  List<DocumentSnapshot> snapshotData;
  List<FoodMonitor> foodData;

  DateTime today;

  int chartDays = 5;
  final Map<int, Widget> chartPeriod = const <int, Widget>{
    5: Text('สัปดาห์'),
    30: Text('เดือน'),
    365: Text('ปี'),
    99999: Text('ทั้งหมด'),
  };

  List<charts.Series<FoodMonitor, DateTime>> caleriesData() {
    List<FoodMonitor> tempData = foodData
        .map((o) => FoodMonitor(
            date: o.date,
            dateString: o.dateString,
            totalCalories: int.parse(o.calories)))
        .toList()
          ..removeWhere((v) => today.difference(v.date).inDays > chartDays);

    if (tempData.isNotEmpty) {
      tempData = groupBy(tempData, (obj) => obj.dateString)
          .map((k, v) => MapEntry(k, v.reduce((a, b) {
                a.totalCalories = a.totalCalories + b.totalCalories;
                return a;
              })))
          .values
          .toList();

      return [
        new charts.Series<FoodMonitor, DateTime>(
          id: 'แคลอรี่',
          colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
          domainFn: (FoodMonitor food, _) =>
              DateTime(food.date.year, food.date.month, food.date.day),
          measureFn: (FoodMonitor food, _) => food.totalCalories,
          data: tempData,
        )
      ];
    }
    return [];
  }

  List<charts.Series<FoodMonitor, DateTime>> eatHoursData() {
    List<FoodMonitor> tempData = foodData
        .map((o) => FoodMonitor(
              date: o.date,
              dateString: o.dateString,
            ))
        .toList()
          ..removeWhere((v) => today.difference(v.date).inDays > chartDays);

    if (tempData.isNotEmpty) {
      tempData = groupBy(tempData, (obj) => obj.dateString)
          .map((k, v) => MapEntry(k, v.reduce((a, b) {
                a.eatHours = getEatHours(a.date, b.date);
                return a;
              })))
          .values
          .toList();
      return [
        new charts.Series<FoodMonitor, DateTime>(
          id: 'ชั่วโมง',
          colorFn: (_, __) => charts.MaterialPalette.lime.shadeDefault,
          domainFn: (FoodMonitor food, _) =>
              DateTime(food.date.year, food.date.month, food.date.day),
          measureFn: (FoodMonitor food, _) => food.eatHours,
          data: tempData,
        )
      ];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;
    DateTime now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
  }

  Future getCameraImage() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 500.0,
    );
    if (image != null) {
      tempImage = image;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => FoodContentAddDialog(
                    image: image,
                    storage: storage,
                    currentUser: currentUser,
                  )));
    }
  }

  Future getGalleryImage() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500.0,
    );
    if (image != null) {
      tempImage = image;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => FoodContentAddDialog(
                    image: image,
                    storage: storage,
                    currentUser: currentUser,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        body: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text("อาหาร"),
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appBarColor1,
                        appBarColor2,
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  tabs: <Tab>[
                    Tab(
                      key: Key('FoodList'),
                      text: "เมนู",
                      // icon: Icon(Icons.add),
                    ),
                    Tab(
                      key: Key('Chart'),
                      text: "รายงาน",
                      // icon: Icon(Icons.add),
                    ),
                  ],
                ),
                // actions: _buildMenuActions(context),
              ),
            ];
          },
          body: buildBody(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () => showRoundedModalBottomSheet(
              context: context,
              builder: (context) => ImageSourceModal(
                    onTabCamera: () => getCameraImage(),
                    onTabGallery: () => getGalleryImage(),
                    isPop: false,
                  )),
          tooltip: 'Pick Image',
          child: Icon(Icons.add_a_photo),
        ),
      ),
    );
  }

  Widget buildBody() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('monitor')
            .document(currentUser.uid)
            .collection('food')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LoadingIndicator();
          snapshotData = snapshot.data.documents
            ..sort((a, b) =>
                b.data['date'].toDate().compareTo(a.data['date'].toDate()));

          foodData = snapshotData
              .map((data) => FoodMonitor.fromSnapshot(data))
              .toList();

          // return snapshotData.isEmpty
          //     ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่ไอคอนมุมขวาล่าง")
          //     : _buildImagesList(context, foodData);

          return TabBarView(
            children: <Widget>[
              snapshotData.isEmpty
                  ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่ไอคอนมุมขวาล่าง")
                  : _buildImagesList(context, foodData),

              snapshotData.isEmpty
                  ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่ไอคอนมุมขวาล่าง")
                  : _buildHistoryChart(),
              // _buildHistory(),
            ],
          );
        });
  }

  Widget _buildImagesList(BuildContext context, List<FoodMonitor> foodData) {
    var foodDataMap = groupBy(foodData, (obj) => obj.dateString);

    List<FoodMonitor> totalCalories = foodDataMap
        .map((k, v) => MapEntry(k, v.reduce((a, b) {
              a.totalCalories = a.totalCalories + b.totalCalories;
              return a;
            })))
        .values
        .toList();

    return ListView.builder(
        padding: const EdgeInsets.only(top: 20.0),
        itemCount: totalCalories.length,
        itemBuilder: (BuildContext context, int index) {
          String key = totalCalories[index].dateString;
          return _buildImagesTitleItem(
              context, foodDataMap[key].toList(), totalCalories[index]);
        });
  }

  Widget _buildImagesTitleItem(
      BuildContext context, List<FoodMonitor> foodList, FoodMonitor total) {
    Widget title = SectionTitle(
      title: socialDate(total.date),
      calories: total.totalCalories.toString(),
      hours: getEatHours(foodList.first.date, foodList.last.date).toString(),
    );

    return Column(
      children:
          foodList.map((data) => _buildImagesListItem(context, data)).toList()
            ..insert(0, title),
    );
  }

  Widget _buildImagesListItem(BuildContext context, FoodMonitor content) {
    // DateTime _date = news.data['record_date'];
    return SafeArea(
      top: false,
      bottom: false,
      child: Center(
        child: SizedBox(
          height: 298.0,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                content.imageUrl != null
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FoodContentEditDialog(
                                  food: content,
                                  storage: storage,
                                  currentUser: currentUser,
                                )))
                    : Alert(
                        context: context,
                        type: AlertType.info,
                        title: "กรุณารอสักครู่",
                        desc: "กำลังโหลดข้อมูลรูปภาพ",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Close",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            width: 120,
                            color: Colors.blue,
                          )
                        ],
                      ).show();
              },
              splashColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
              highlightColor: Colors.transparent,
              child: FoodContent(
                food: content,
                tempImage: tempImage,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int getEatHours(DateTime first, DateTime last) {
    if (first == null || last == null) return 0;
    return first.difference(last).inHours;
  }

  Widget _buildHistoryChart() {
    return ListView(children: <Widget>[
      SizedBox(
        height: 40,
        child: CupertinoSegmentedControl<int>(
          children: chartPeriod,
          onValueChanged: (int newValue) {
            setState(() {
              chartDays = newValue;
            });
          },
          groupValue: chartDays,
        ),
      ),
      SizedBox(height: 10),
      Container(
        height: 240,
        child: TimeSeriesBar(caleriesData(), animate: true, unit: 'แคลอรี่'),
      ),
      SizedBox(height: 30),
      Container(
        height: 240,
        child: TimeSeriesBar(eatHoursData(), animate: true, unit: 'ชั่วโมง'),
      ),
    ]);
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key key,
    this.title,
    this.calories,
    this.hours,
  }) : super(key: key);

  final String title;
  final String calories;
  final String hours;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 8.0, 6.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: Theme.of(context).textTheme.headline),
          ),
        ),
        Text(' $calories แคลอรี่', style: Theme.of(context).textTheme.subhead),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 12),
            child: Text('$hours ชั่วโมง',
                style: Theme.of(context).textTheme.subhead),
          ),
        )

        // style: TextStyle(color: Colors.green, fontSize: 16))
      ],
    );
  }
}

class FoodContent extends StatelessWidget {
  const FoodContent({Key key, @required this.food, this.tempImage})
      : assert(food != null),
        super(key: key);

  final FoodMonitor food;
  final File tempImage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.title.copyWith(color: Colors.white);
    TextStyle subtitleStyle =
        theme.textTheme.subtitle.copyWith(color: Colors.white);

    final List<Widget> children = <Widget>[
      // Photo and title.
      SizedBox(
        height: 274.0,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Ink.image(
                image: food.imageUrl != null
                    ? CachedNetworkImageProvider(food.imageUrl)
                    : FileImage(tempImage),
                fit: BoxFit.cover,
                child: Container(),
              ),
            ),
            Positioned(
              bottom: 36.0,
              left: 16.0,
              right: 16.0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Text(
                  food.menu,
                  style: titleStyle,
                ),
              ),
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "${food.calories} แคลอรี่",
                    style: subtitleStyle,
                  )),
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomRight,
                child: Text(
                  DateFormat.Hm().format(food.date),
                  style: subtitleStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class FoodContentEditDialog extends StatefulWidget {
  const FoodContentEditDialog(
      {Key key,
      @required this.food,
      @required this.storage,
      @required this.currentUser})
      : assert(food != null),
        super(key: key);

  final FoodMonitor food;
  final FirebaseStorage storage;
  final FirebaseUser currentUser;

  @override
  _FoodContentEditDialogState createState() => _FoodContentEditDialogState();
}

class _FoodContentEditDialogState extends State<FoodContentEditDialog> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _textMenuController;
  TextEditingController _textCalController;

  @override
  void initState() {
    super.initState();
    _textMenuController = TextEditingController(text: widget.food.menu);
    _textCalController = TextEditingController(text: widget.food.calories);
  }

  bool _autovalidate = false;

  void _handleSubmitted() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final FormState form = _formKey.currentState;
        if (!form.validate()) {
          _autovalidate = true; // Start validating on every change.
          showInSnackBar('No data');
        } else {
          form.save();
          _saveData();
          Navigator.pop(context);
        }
      }
    } on SocketException catch (_) {
      showInSnackBar("No Internet Connection");
      return;
    }
  }

  String _validateInput(String value) {
    if (value.isEmpty) return 'This field is required.';
    return null;
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: GradientAppBar(
        title: Text('แก้ไข'),
        gradient: LinearGradient(colors: [appBarColor1, appBarColor2]),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidate: _autovalidate,
          child: ListView(
            // padding: EdgeInsets.only(top: 8),
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width,
                height: 300,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(widget.food.imageUrl),
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.today, color: Colors.grey[500]),
                title:
                    Text(DateFormat('MMM d, y  H:mm').format(widget.food.date)),
                onTap: () {
                  DatePicker.showDateTimePicker(
                    context,
                    showTitleActions: true,
                    onChanged: (date) {
                      setState(() {
                        widget.food.date = date;
                      });
                    },
                    onConfirm: (date) {
                      setState(() {
                        widget.food.date = date;
                      });
                    },
                    currentTime: widget.food.date,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.restaurant, color: Colors.grey[500]),
                title: TextFormField(
                    controller: _textMenuController,
                    validator: _validateInput,
                    onSaved: (value) {
                      widget.food.menu = value;
                    }),
                trailing: Text('   '),
              ),
              ListTile(
                leading:
                    Icon(Icons.format_list_numbered, color: Colors.grey[500]),
                title: TextFormField(
                    controller: _textCalController,
                    validator: _validateInput,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    onSaved: (value) {
                      widget.food.calories = value;
                    }),
                trailing: Text('Cal'),
              ),
              SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: RaisedButton(
                  elevation: 1.0,
                  onPressed: _handleSubmitted,
                  padding: EdgeInsets.all(12),
                  color: Colors.blueAccent,
                  child: Text('Save',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: RaisedButton(
                  elevation: 1.0,
                  onPressed: () {
                    // final ConfirmAction action = await confirmDialog(context);
                    // if (action.toString() == 'ConfirmAction.DELETE') {
                    // _deleteData();

                    // }
                    // Navigator.pop(context);
                    Alert(
                      context: context,
                      type: AlertType.warning,
                      title: "ยืนยัน",
                      desc: "ต้องการลบข้อมูล?",
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
                            _deleteData();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          color: Colors.red,
                        )
                      ],
                    ).show();
                  },
                  padding: EdgeInsets.all(12),
                  color: Colors.redAccent,
                  child: Text('Delete',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _deleteData() {
    widget.storage.ref().child(widget.food.uploadPath).delete();
    Firestore.instance
        .collection('monitor')
        .document(widget.currentUser.uid)
        .collection('food')
        .document(widget.food.documentID)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  void _saveData() {
    int timestamp = widget.food.date.millisecondsSinceEpoch;

    if (timestamp.toString() != widget.food.documentID) {
      Firestore.instance
          .collection('monitor')
          .document(widget.currentUser.uid)
          .collection('food')
          .document(widget.food.documentID)
          .delete()
          .catchError((e) {
        print(e);
      });
    }

    DocumentReference monitor = Firestore.instance
        .collection("monitor")
        .document(widget.currentUser.uid)
        .collection('food')
        .document(timestamp.toString());
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(monitor, widget.food.getMapData());
    });
  }

  Future<ConfirmAction> confirmDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ยืนยัน"),
          content: Text("ลบข้อมูล"),
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

class FoodContentAddDialog extends StatefulWidget {
  const FoodContentAddDialog(
      {Key key,
      @required this.storage,
      @required this.currentUser,
      @required this.image})
      : assert(image != null),
        super(key: key);

  final FirebaseStorage storage;
  final FirebaseUser currentUser;
  final File image;

  @override
  _FoodContentAddDialogState createState() => _FoodContentAddDialogState();
}

class _FoodContentAddDialogState extends State<FoodContentAddDialog> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _textMenuController;
  TextEditingController _textCalController;
  Map<String, dynamic> monitorData = {
    'date': DateTime.now(),
    'menu': '',
    'calories': ''
  };

  bool _autovalidate = false;

  void _handleSubmitted() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print("Connected");
        final FormState form = _formKey.currentState;
        if (!form.validate()) {
          _autovalidate = true; // Start validating on every change.
          showInSnackBar('No Data');
        } else {
          form.save();
          _saveData();
          Navigator.pop(context);
        }
      }
    } on SocketException catch (_) {
      showInSnackBar("No Internet Connection");
      return;
    }
  }

  String _validateInput(String value) {
    if (value.isEmpty) return 'This field is required.';
    return null;
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: GradientAppBar(
          title: Text('เพิ่มข้อมูล'),
          gradient: LinearGradient(colors: [appBarColor1, appBarColor2]),
        ),
        body: SafeArea(
            child: Form(
          key: _formKey,
          autovalidate: _autovalidate,
          child: ListView(
            padding: EdgeInsets.only(top: 8),
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width,
                height: 300,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    image: DecorationImage(
                      image: FileImage(widget.image),
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.restaurant, color: Colors.grey[500]),
                title: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'ชื่อเมนู',
                    ),
                    controller: _textMenuController,
                    validator: _validateInput,
                    onSaved: (value) {
                      monitorData['menu'] = value;
                    }),
                trailing: Text('   '),
              ),
              SizedBox(height: 16),
              ListTile(
                leading:
                    Icon(Icons.format_list_numbered, color: Colors.grey[500]),
                title: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'ปริมาณแคลลอรี่',
                    ),
                    controller: _textCalController,
                    validator: _validateInput,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    onSaved: (value) {
                      monitorData['calories'] = value;
                    }),
                trailing: Text('Cal'),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RaisedButton(
                  elevation: 1.0,
                  onPressed: _handleSubmitted,
                  padding: EdgeInsets.all(12),
                  color: Colors.blueAccent,
                  child: Text('Add',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        )));
  }

  void _saveData() {
    int timestamp = monitorData['date'].millisecondsSinceEpoch;
    File imageFile = widget.image;

    String mimeType = mime(widget.image.uri.path);

    if (mimeType == 'image/jpeg') {
      imageFile = resizeJpg(widget.image);
    }

    if (mimeType == 'image/png') {
      imageFile = pngToJpg(widget.image);
    }

    DocumentReference monitor = Firestore.instance
        .collection("monitor")
        .document(widget.currentUser.uid)
        .collection('food')
        .document(timestamp.toString());
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(monitor, monitorData);
    });

    final uploadPath = '/food_images/' +
        widget.currentUser.uid +
        '/' +
        timestamp.toString() +
        '.jpg';
    final StorageReference ref = widget.storage.ref().child(uploadPath);
    final StorageUploadTask uploadTask = ref.putFile(imageFile);

    uploadTask.onComplete
        .then((snapshot) => snapshot.ref.getDownloadURL())
        .then((url) {
      monitorData['imageUrl'] = url;
      monitorData['uploadPath'] = uploadPath;

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(monitor, monitorData);
      });
    });
  }

  File pngToJpg(File pngFile) {
    ImagePackage.Image pngImage =
        ImagePackage.decodePng(pngFile.readAsBytesSync());

    ImagePackage.Image jpgImage = ImagePackage.copyResize(pngImage, width: 500);

    pngFile.writeAsBytesSync(ImagePackage.encodeJpg(jpgImage, quality: 80));

    return pngFile;
  }

  File resizeJpg(File jpgFile) {
    ImagePackage.Image temp = ImagePackage.decodeJpg(jpgFile.readAsBytesSync());

    ImagePackage.Image jpgImage = ImagePackage.copyResize(temp, width: 500);

    jpgFile.writeAsBytesSync(ImagePackage.encodeJpg(jpgImage, quality: 80));

    return jpgFile;
  }
}

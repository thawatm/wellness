import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
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
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:image/image.dart' as ImagePackage;
import 'package:mime_type/mime_type.dart';

class FoodMonitorPage extends StatefulWidget {
  @override
  _FoodMonitorPageState createState() => _FoodMonitorPageState();
}

class _FoodMonitorPageState extends State<FoodMonitorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollViewController;
  File tempImage;

  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://bsp-kiosk.appspot.com');
  String uid;
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
            totalServing: int.parse(o.serving)))
        .toList()
          ..removeWhere((v) => today.difference(v.date).inDays > chartDays);

    if (tempData.isNotEmpty) {
      tempData = groupBy(tempData, (obj) => obj.dateString)
          .map((k, v) => MapEntry(k, v.reduce((a, b) {
                a.totalServing = a.totalServing + b.totalServing;
                return a;
              })))
          .values
          .toList();

      return [
        new charts.Series<FoodMonitor, DateTime>(
          id: 'Serving',
          colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
          domainFn: (FoodMonitor food, _) =>
              DateTime(food.date.year, food.date.month, food.date.day),
          measureFn: (FoodMonitor food, _) => food.totalServing,
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
    uid = ScopedModel.of<StateModel>(context).uid;
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
                    uid: uid,
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
                    uid: uid,
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
                title: Text("ผักผลไม้"),
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.appBarColor1,
                        AppTheme.appBarColor2,
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  tabs: <Tab>[
                    Tab(
                      key: Key('FoodList'),
                      text: "ผักผลไม้",
                    ),
                    Tab(
                      key: Key('Chart'),
                      text: "กราฟ",
                    ),
                  ],
                ),
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
            .collection('wellness_data')
            .document(uid)
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

    List<FoodMonitor> totalServing = foodDataMap
        .map((k, v) => MapEntry(k, v.reduce((a, b) {
              a.totalServing = a.totalServing + b.totalServing;
              return a;
            })))
        .values
        .toList();

    return ListView.builder(
        padding: const EdgeInsets.only(top: 20.0),
        itemCount: totalServing.length,
        itemBuilder: (BuildContext context, int index) {
          String key = totalServing[index].dateString;
          return _buildImagesTitleItem(
              context, foodDataMap[key].toList(), totalServing[index]);
        });
  }

  Widget _buildImagesTitleItem(
      BuildContext context, List<FoodMonitor> foodList, FoodMonitor total) {
    Widget title = SectionTitle(
      title: socialDate(total.date),
      serving: total.totalServing.toString(),
      // hours: getEatHours(foodList.first.date, foodList.last.date).toString(),
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
                                  uid: uid,
                                )))
                    : Alert.alert(context,
                            title: "กรุณารอสักครู่",
                            content: "กำลังโหลดข้อมูลรูปภาพ")
                        .then((_) => Navigator.pop(context));
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
          selectedColor: Colors.blueAccent,
          borderColor: Colors.blueAccent,
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
        child: TimeSeriesBar(caleriesData(), animate: true, unit: 'Serving'),
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
    this.serving,
    this.hours,
  }) : super(key: key);

  final String title;
  final String serving;
  final String hours;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 8.0, 6.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: Theme.of(context).textTheme.headline5),
          ),
        ),
        Text(' $serving Serving(s)',
            style: Theme.of(context).textTheme.subtitle1),
        // Expanded(
        //   child: Container(
        //     alignment: Alignment.centerRight,
        //     padding: EdgeInsets.only(right: 12),
        //     child: Text('$hours ชั่วโมง',
        //         style: Theme.of(context).textTheme.subtitle1),
        //   ),
        // )

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
        theme.textTheme.headline6.copyWith(color: Colors.white);
    TextStyle subtitleStyle =
        theme.textTheme.subtitle2.copyWith(color: Colors.white);
    AssetImage blankImage = AssetImage('assets/images/blank.png');

    final List<Widget> children = <Widget>[
      // Photo and title.
      SizedBox(
        height: 274.0,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Ink.image(
                image: food.imageUrl != null
                    ? (CachedNetworkImageProvider(food.imageUrl) ?? blankImage)
                    : blankImage,
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
                    "${food.serving} Serving(s)",
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
      @required this.uid})
      : assert(food != null),
        super(key: key);

  final FoodMonitor food;
  final FirebaseStorage storage;
  final String uid;

  @override
  _FoodContentEditDialogState createState() => _FoodContentEditDialogState();
}

class _FoodContentEditDialogState extends State<FoodContentEditDialog> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _textMenuController;
  TextEditingController _textServController;

  @override
  void initState() {
    super.initState();
    _textMenuController = TextEditingController(text: widget.food.menu);
    _textServController = TextEditingController(text: widget.food.serving);
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
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
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
                    controller: _textServController,
                    validator: _validateInput,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    onSaved: (value) {
                      widget.food.serving = value;
                    }),
                trailing: Text('Serving(s)'),
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
                    Alert.confirm(
                      context,
                      title: "ยืนยัน",
                      content: "ต้องการลบข้อมูล?",
                    ).then((int ret) => ret == Alert.OK ? _deleteData() : null);
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
        .collection('wellness_data')
        .document(widget.uid)
        .collection('food')
        .document(widget.food.documentID)
        .delete()
        .catchError((e) {
      print(e);
    });
    Navigator.pop(context);
  }

  void _saveData() {
    int timestamp = widget.food.date.millisecondsSinceEpoch;

    if (timestamp.toString() != widget.food.documentID) {
      Firestore.instance
          .collection('wellness_data')
          .document(widget.uid)
          .collection('food')
          .document(widget.food.documentID)
          .delete()
          .catchError((e) {
        print(e);
      });
    }

    if (widget.food.menu == '') widget.food.menu = 'ผักผลไม้';

    Firestore.instance
        .collection('wellness_data')
        .document(widget.uid)
        .collection('food')
        .document(timestamp.toString())
        .setData(widget.food.getMapData());
  }
}

class FoodContentAddDialog extends StatefulWidget {
  const FoodContentAddDialog(
      {Key key,
      @required this.storage,
      @required this.uid,
      @required this.image})
      : assert(image != null),
        super(key: key);

  final FirebaseStorage storage;
  final String uid;
  final File image;

  @override
  _FoodContentAddDialogState createState() => _FoodContentAddDialogState();
}

class _FoodContentAddDialogState extends State<FoodContentAddDialog> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _textMenuController = TextEditingController(text: '');
  TextEditingController _textServController = TextEditingController(text: '1');
  Map<String, dynamic> monitorData = {
    'date': DateTime.now(),
    'menu': '',
    'serving': ''
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
          Alert.toast(context, "ไม่มีข้อมูล");
        } else {
          form.save();
          _saveData();
          Navigator.pop(context);
        }
      }
    } on SocketException catch (_) {
      Alert.toast(context, "No Internet Connection");
      return;
    }
  }

  String _validateInput(String value) {
    if (value.isEmpty) return 'This field is required.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: GradientAppBar(
          title: Text('เพิ่มข้อมูล'),
          gradient: LinearGradient(
              colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
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
                    // validator: _validateInput,
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
                      hintText: 'ปริมาณผักผลไม้',
                    ),
                    controller: _textServController,
                    validator: _validateInput,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    onSaved: (value) {
                      monitorData['serving'] = value;
                    }),
                trailing: Text('Serving(s)'),
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
    try {
      int timestamp = monitorData['date'].millisecondsSinceEpoch;
      File imageFile = widget.image;

      String mimeType = mime(widget.image.uri.path);

      if (mimeType == 'image/jpeg') {
        imageFile = resizeJpg(widget.image);
      }

      if (mimeType == 'image/png') {
        imageFile = pngToJpg(widget.image);
      }

      final uploadPath =
          '/food_images/' + widget.uid + '/' + timestamp.toString() + '.jpg';
      final StorageReference ref = widget.storage.ref().child(uploadPath);
      final StorageUploadTask uploadTask = ref.putFile(imageFile);

      uploadTask.onComplete
          .then((snapshot) => snapshot.ref.getDownloadURL())
          .then((url) {
        monitorData['imageUrl'] = url;
        monitorData['uploadPath'] = uploadPath;

        if (monitorData['menu'] == '') monitorData['menu'] = 'ผักผลไม้';

        Firestore.instance
            .collection('wellness_data')
            .document(widget.uid)
            .collection('food')
            .document(timestamp.toString())
            .setData(monitorData);
      });
    } catch (e) {
      print(e);
      Alert.toast(context, 'อัพโหลดรูปภาพไม่ได้');
    }
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

import 'package:flutter/material.dart';

typedef Callback = void Function(String text);

class EditDialog extends StatelessWidget {
  const EditDialog(
      {Key key,
      @required this.title,
      @required this.initialValue,
      @required this.textInputType,
      this.buttonLabel: 'OK',
      @required this.onSave})
      : assert(title != null),
        super(key: key);
  final String title;
  final String initialValue;
  final Callback onSave;
  final TextInputType textInputType;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller =
        TextEditingController(text: initialValue);
    return Container(
        height: 300,
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.centerLeft,
            ),
            Container(
              child: TextFormField(
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
                controller: _controller,
                keyboardType: textInputType,
              ),
            ),
            SizedBox(height: 36),
            Container(
              height: 50,
              width: 150,
              child: RaisedButton(
                elevation: 7.0,
                onPressed: () {
                  onSave(_controller.value.text);
                  Navigator.pop(context);
                },
                padding: EdgeInsets.all(12),
                color: Colors.blueAccent,
                child: Text(this.buttonLabel,
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ));
  }
}

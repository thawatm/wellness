import 'package:flutter/material.dart';

class ImageSourceModal extends StatelessWidget {
  ImageSourceModal(
      {Key key, this.onTabCamera, this.onTabGallery, this.isPop = true});
  final void Function() onTabCamera;
  final void Function() onTabGallery;
  final bool isPop;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              onTabGallery();
              if (isPop) Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.image, size: 60, color: Colors.green),
                Text(
                  'Gallery',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(width: 70),
          InkWell(
            onTap: () {
              onTabCamera();
              if (isPop) Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.camera_alt, size: 60, color: Colors.purple),
                Text(
                  'Camera',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

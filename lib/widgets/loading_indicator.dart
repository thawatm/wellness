import 'package:flutter/cupertino.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: const Center(
        child: CupertinoActivityIndicator(radius: 15),
      ),
    );
  }
}

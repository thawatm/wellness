import 'package:wellness/dashboard/app_theme.dart';
import 'package:flutter/material.dart';

class TitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;

  final Widget targetPage;
  final Function onTab;
  final bool isMenuOption;

  const TitleView(
      {Key key,
      this.titleTxt: "",
      this.subTxt: "",
      this.targetPage,
      this.onTab,
      this.isMenuOption: true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                titleTxt,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: AppTheme.lightText,
                ),
              ),
            ),
            !isMenuOption
                ? SizedBox()
                : InkWell(
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    // onTap: () => Navigator.of(context).pushNamed(routeName),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => targetPage),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            height: 38,
                            width: 26,
                            child: Icon(
                              Icons.more_vert,
                              color: AppTheme.darkText,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

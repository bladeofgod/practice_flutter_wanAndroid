import 'package:flutter/material.dart';

class IconTextWidget extends StatelessWidget{

  Widget icon;
  Widget text;
  double padding;

  IconTextWidget({@required this.icon,@required this.text,@required this.padding = 0});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: padding),
            child: icon,
          ),
          Expanded(
            flex: 1,
            child: text,
          )
        ],
      ),
    );
  }

}
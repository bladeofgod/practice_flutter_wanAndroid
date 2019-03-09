import 'package:flutter/material.dart';
import '../widget/marquee_widget.dart';

class TitleBar extends StatefulWidget implements PreferredSizeWidget {
  bool isShowBack = true;
  String title = "";
  Widget leftButton;
  List<Widget> rightButtons;

  TitleBar(
      {this.leftButton, this.isShowBack = true, this.title, this.rightButtons});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new TitleBarState();
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(56.0);

  static Widget textButton(
      {String text = '', Color color = Colors.white, Function() press}) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Text(
          text,
          style: TextStyle(color: color),
        ),
      ),
      onTap: press,
    );
  }

  static Widget iconButton(
      {IconData icon, Color color = Colors.white, Function() function}) {
    return IconButton(
      padding: EdgeInsets.all(2),
      icon: Icon(
        icon,
        color: color,
      ),
      onPressed: function,
    );
  }
}

class TitleBarState extends State<TitleBar> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration:BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xbf46be39), Color(0xff46be39)],
        begin: Alignment.centerLeft,end: Alignment.centerRight)
      ),
      child: Stack(
        children: <Widget>[
          Offstage(
            offstage: !widget.isShowBack,
            child: Container(
              alignment: Alignment.centerLeft,
              child: widget.leftButton == null ?
                  IconButton(icon: Icon(Icons.arrow_back,color: Colors.white,), onPressed: (){
                    Navigator.of(context).pop();
                  },) : widget.leftButton,
            ),
          ),
          Container(margin: EdgeInsets.symmetric(horizontal: 45),
          child: Center(
            child: MarqueeWidget(text: widget.title,height: 56,
              width: MediaQuery.of(context).size.width - 90,
            style: TextStyle(fontSize: 18,color: Colors.white),),
          ),),
          Positioned(
            right: 0,
            height: 56,
            child: Container(
              child: widget.rightButtons != null ? Row(children:widget.rightButtons,) : null,
            ),
          ),
        ],
      ),
    );
  }
}

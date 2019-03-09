import 'package:flutter/material.dart';
import '../model/article.dart';
import '../net/dio_manager.dart';
import '../ui/webview_page.dart';
import '../utils/color.dart';
import '../utils/common.dart';
import '../utils/textsize.dart';


class CollectionArticleWidget extends StatefulWidget{

  Article article;

  CollectionArticleWidget(this.article);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CollectionArticleWidgetState();
  }

}

class CollectionArticleWidgetState extends State<CollectionArticleWidget> {

  Article article;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    article = widget.article;
    return GestureDetector(
      onTap: (){
        CommonUtils.push(context, WebViewPage(title: article.title,url: article.link,));
      },
      child: Card(
        margin: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.android,
                    color: ColorConst.color_primary,
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "${article.author}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color:ColorConst.color_333,
                          fontSize:TextSizeConst.smallTextSize
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text(
                    "${article.title}",
                    style: TextStyle(
                      color:ColorConst.color_333,
                      fontSize:TextSizeConst.middleTextSize
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.access_time,
                    color: Colors.black45,
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "${article.niceDate}",
                        style: TextStyle(
                          color:ColorConst.color_555,
                          fontSize:TextSizeConst.smallTextSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  collect(){
    String url = "";
    if(!article.collect){
      url = "lg/collect/${article.id}/json";
    }else{
      url = "lg/uncollect_originId/${article.id}/json";
    }

    CommonUtils.showLoadingDialog(context);
    DioManager.singleton.post(url).whenComplete((){
      Navigator.pop(context);
    }).then((result){
      if(result != null){
        setState(() {
          article.collect = !article.collect;
        });
      }
    });

  }

}













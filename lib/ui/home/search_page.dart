import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../db/db.dart';
import '../../generated/i18n.dart';
import '../../model/hot_word.dart';
import '../../net/dio_manager.dart';
import '../../ui/home/search_result_page.dart';
import '../../utils/color.dart';
import '../../utils/common.dart';
import '../../utils/textsize.dart';
import '../../widget/icon_text_widget.dart';


class SearchPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchPageState();
  }

}

class SearchPageState extends State<SearchPage> {

  TextEditingController _controller;
  List<HotWord> hotWords = List();
  List<Map> histories = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = TextEditingController();

    getHistory();
    getHotWord();

  }

  void getHistory(){
    DbManager.singleton.getHistory().then((list){
      setState(() {
        histories.clear();
        histories.addAll(list);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _title(context),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: histories.length + 1,
              itemBuilder: (context,index){
                if(index == 0){
                  return Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            S.of(context).search_for_hot_words,
                            textAlign: TextAlign.left,
                            style: TextStyle(color: ColorConst.color_333),
                          ),
                        ),
                        hotWords.length >0 ?
                            Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: _buildWrapItem(),
                            ) : SizedBox(),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Text(
                                  S.of(context).history_record,
                                  style: TextStyle(
                                    color: ColorConst.color_333
                                  ),
                                ),
                              ),
                              InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(S.of(context).clear,
                                      style: TextStyle(
                                          color: ColorConst.color_333)),
                                ),
                                onTap: (){
                                  DbManager.singleton.clear().then((_){
                                    getHistory();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }else{
                  return _buildHistoryItem(histories[index -  1]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(BuildContext context){
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: ColorConst.color_white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius:BorderRadius.circular(5.0)
              ),
              child: IconTextWidget(icon: Icon(
                Icons.search,size: 20,color: ColorConst.color_999,
              ), text: TextField(
                controller: _controller,
                keyboardType: TextInputType.text,
                autofocus: false,
                obscureText:false ,
                style: TextStyle(
                  fontSize:TextSizeConst.smallTextSize,
                  color:ColorConst.color_333,
                ),
                decoration: InputDecoration(
                  hintText:S.of(context).please_enter_a_keyword,
                  contentPadding:EdgeInsets.all(6.0),
                  border:InputBorder.none
                ),
              )),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 60,
              height: 30,
              child: RaisedButton(
                elevation: 0,
                highlightElevation: 0,
                color: ColorConst.color_primary,
                child: Text(
                  S.of(context).search,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorConst.color_white,fontSize: 12),
                  maxLines: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:BorderRadius.circular(30)
                ),
                onPressed: (){
                  var key = _controller.text.toString();
                  if(key.isEmpty){
                    Fluttertoast.showToast(msg: S.of(context).keyword_cannot_be_empty);
                    return;
                  }
                  _goToSearchResultPage(key);
                  _controller.text = "";
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getHotWord() {
    DioManager.singleton.get("hotkey/json").then((result) {
      if (result != null) {
        List<HotWord> datas = HotWord.parseList(result.data);
        setState(() {
          hotWords.clear();
          hotWords.addAll(datas);
        });
      }
    });
  }

  _buildWrapItem() {
    List<Widget> items = List();
    for (var hotWord in hotWords) {
      Widget item = InkWell(
        onTap: () {
          _goToSearchResultPage(hotWord.name);
        },
        child: Container(
          constraints: BoxConstraints(minHeight: 30),
          padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: ColorConst.color_ccc.withAlpha(100),
          ),
          child: Text(
            hotWord.name,
            style: TextStyle(
                color: Colors.deepOrangeAccent,
                fontSize: TextSizeConst.smallTextSize),
          ),
        ),
      );
      items.add(item);
    }
    return items;
  }

  Widget _buildHistoryItem(Map history) {
    var name = history["name"];
    return InkWell(
      onTap: () {
        _goToSearchResultPage(name);
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.android,
              color: ColorConst.color_primary,
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  name,
                  textAlign: TextAlign.start,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _goToSearchResultPage(String name) async {
    var b = await DbManager.singleton.hasSameData(name);
    if (!b) {
      DbManager.singleton.save(name);
    }
    CommonUtils.push(context, SearchResultPage(name)).then((_) {
      getHistory();
    });
  }







}
















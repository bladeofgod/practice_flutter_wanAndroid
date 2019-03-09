import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'model/user.dart';
import 'redux/main_redux.dart';
import 'redux/user_reducer.dart';
import 'utils/const.dart';
import 'utils/sp.dart';


class FlashPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FlashPageState();
  }

}

class FlashPageState extends State<FlashPage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 4)).whenComplete((){
      Navigator.pushReplacementNamed(context, 'main');
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    initData();
  }

  void initData(){
    int userId;
    String userName;
    Store<MainRedux> store = StoreProvider.of(context);
    SpManager.singleton.getString(Const.USERNAME).then((name){
      userName = name;
      if(userId != null && userId > 0 && userName != null && userName.isNotEmpty){
        store.dispatch(UpdateUserAction(User(userId, userName)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Image.network(
      'http://b.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc4802878ba34dbb6fd536633a0.jpg',
      fit: BoxFit.fitHeight,
    );
  }
}














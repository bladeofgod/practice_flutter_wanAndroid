import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../generated/i18n.dart';
import '../model/user.dart';
import '../net/dio_manager.dart';
import '../redux/main_redux.dart';
import '../redux/user_reducer.dart';
import '../utils/const.dart';
import '../utils/sp.dart';


class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoginPageState();
  }

}

class LoginPageState extends State<LoginPage> with TickerProviderStateMixin {

  bool isLogin = false;

  var _userController = TextEditingController();
  var _pwdController = TextEditingController();

  Store _store;
  Store get store => _store;

  onLoginClick() async{
    if(_userController.text.toString().isEmpty){
      Fluttertoast.showToast(msg: S.of(context).username_can_not_be_empty, toastLength: Toast.LENGTH_SHORT);
      return;
    }
    if (_pwdController.text.toString().isEmpty) {
      Fluttertoast.showToast(msg: S.of(context).pwd_can_not_be_empty, toastLength: Toast.LENGTH_SHORT);
      return;
    }
    login();
  }

  loading(bool isLoading){
    setState(() {
      isLogin = isLoading;
    });
  }

  login() async{
    loading(true);
    DioManager.singleton
      .post("user/login",
              data: FormData.from({
                "username":_userController.text.toString(),
                "password":_pwdController.text.toString(),
              })).whenComplete((){
                loading(false);
    }).then((result){
      if(result != null){
        var id = result.data["id"];
        var username = result.data["username"];
        SpManager.singleton.save(Const.ID, id);
        SpManager.singleton.save(Const.USERNAME, username);
        Fluttertoast.showToast(msg: S.of(context).login_success);
        Navigator.of(context).pop();
      }

    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var loginButtonWidget;
    if(isLogin){
      AnimationController animationController = new AnimationController(vsync: this,
      duration: Duration(milliseconds: 2000));
      Animation<Color> animation = new Tween(begin: Colors.white,end: Colors.black).animate(animationController);
      loginButtonWidget = CircularProgressIndicator(
        backgroundColor: Colors.white,
        valueColor: animation,
      );
    }else{
      loginButtonWidget = Text(S.of(context).login,style: TextStyle(color: Colors.white),);
    }

    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: FlutterLogo(
          size: 80,
        ),
      ),
    );


    final userNmae = Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(50.0)
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        controller: _userController,
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          hintText:S.of(context).please_input_username,
          contentPadding:EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border:InputBorder.none
        ),
      ),
    );

    final password = Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(50.0)),
      child: TextField(
          controller: _pwdController,
          autofocus: false,
          obscureText: true,
          decoration: InputDecoration(
              hintText: S.of(context).please_input_pwd,
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: InputBorder.none)),
    );

    final loginButton = SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          color: Colors.lightBlueAccent,
          onPressed: onLoginClick,
          child: loginButtonWidget,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
      width: double.infinity,
      height: 80,
    );
    final forgotLabel = FlatButton(
      child: Text(
        S.of(context).forget_pwd,
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );


    return StoreBuilder<MainRedux>(
      builder: (context,store){
        _store = store;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    logo,
                    SizedBox(height: 48.0),
                    userNmae,
                    SizedBox(height: 8.0),
                    password,
                    SizedBox(height: 24.0),
                    loginButton,
                    forgotLabel,
                  ],
                ),
              ),
              margin: EdgeInsets.fromLTRB(20, 100, 20, 0),
            ),
          ),
        );
      },
    );
  }
}




















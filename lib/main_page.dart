import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:redux/redux.dart';
import 'event/error_event.dart';
import 'generated/i18n.dart';
import 'net/dio_manager.dart';
import 'redux/main_redux.dart';
import 'redux/user_reducer.dart';
import 'ui/home/collection_page.dart';
import 'ui/home/home_page.dart';
import 'ui/home/search_page.dart';
import 'ui/knowledge/knowledge_page.dart';
import 'ui/login_page.dart';
import 'ui/navigation/navigation_page.dart';
import 'ui/project/project_page.dart';
import 'ui/webview_page.dart';
import 'utils/color.dart';
import 'utils/common.dart';
import 'utils/textsize.dart';
import 'utils/const.dart';
import 'utils/eventbus.dart';
import 'utils/sp.dart';
import 'widget/titlebar.dart';


class MainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new MainPageState();
  }

}

class MainPageState extends State<MainPage> {

  var appBarTitles;
  int _tabIndex = 0;
  var _pageCtr = PageController(initialPage: 0,keepPage: true);
  DateTime _lastPressedAt;//上次点击时间

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    EventUtil.eventBus.on().listen((event){
      if(event is ErrorEvent){
        Fluttertoast.showToast(msg: event.errorMsg);
        if(event.errorCode == -1001){
          //login
          CommonUtils.pushIOS(context, LoginPage());
        }
      }else if(event is DioError){
        String errorMsg = "";
        switch(event.type){
          case DioErrorType.DEFAULT:
            errorMsg = S.of(context).network_error;
            break;
          case DioErrorType.CONNECT_TIMEOUT:
            errorMsg = S.of(context).connect_timeout;
            break;
          case DioErrorType.RECEIVE_TIMEOUT:
            errorMsg = S.of(context).receive_timeout;
            break;
          case DioErrorType.RESPONSE:
            errorMsg = S.of(context).server_error;
            break;
          case DioErrorType.CANCEL:
            errorMsg = S.of(context).request_cancel;
            break;
          default:
            break;
        }
        Fluttertoast.showToast(msg: errorMsg);
      }
    });

  }

  GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {

    appBarTitles=[S.of(context).home, S.of(context).knowledge_system, S.of(context).navigation, S.of(context).project];
    // TODO: implement build
    return WillPopScope(
      child: Scaffold(
        appBar: TitleBar(
          isShowBack: true,
          leftButton: Builder(builder: (cxt){
            return IconButton(
              icon: Icon(Icons.menu,color: Colors.white,),
              onPressed: (){
                Scaffold.of(context).openDrawer();
              },
            );
          }),
          title: appBarTitles[_tabIndex],
          rightButtons: <Widget>[
            TitleBar.iconButton(
              icon: Icons.search,
              color:Colors.white,
              press:(){
                CommonUtils.push(context, SearchPage());
              }
            )
          ],
        ),
        drawer: Drawer(
          child: _drawerChild(),
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageCtr,
          children: <Widget>[
            HomePage(),
            KnowledgePage(),
            NavigationPage(),
            ProjectPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabIndex,
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.green,
          onTap: (index)=> _tap(index),
          items: [
            BottomNavigationBarItem(
              title:Text(appBarTitles[0]),icon:Icon(Icons.home)
            ),
            BottomNavigationBarItem(
                title: Text(appBarTitles[1]), icon: Icon(Icons.theaters)),
            BottomNavigationBarItem(
                title: Text(appBarTitles[2]), icon: Icon(Icons.navigation)),
            BottomNavigationBarItem(
                title: Text(appBarTitles[3]), icon: Icon(Icons.print)),
          ],
        ),
      ),
      onWillPop: ()async{
        if(_lastPressedAt == null
            || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 2)){
          //两次点击间隔超过2秒则重新计时
          _lastPressedAt = DateTime.now();
          Fluttertoast.showToast(msg: S.of(context).press_again_to_exit_the_app);
          return false;

        }
        return true;
      },
    );
  }
  _tap(int index){
    setState(() {
      _tabIndex = index;
      _pageCtr.jumpToPage(index);
    });
  }
  Store _store;

  Widget _drawerChild(){
    return Column(
      children: <Widget>[
        ClipPath(
          clipper: ArcClipper(),
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            width: double.infinity,
            height: 200,
            imageUrl: "http://t2.hddhhn.com/uploads/tu/201612/98/st93.png",
            placeholder: ImageIcon(
              AssetImage("assets/logo.png"),
              size: 100,
            ),
            errorWidget: Icon(Icons.info_outline),
          ),
        ),
        SizedBox(
          width: 0,
          height: 5,
        ),
        _menuItem(S.of(context).collection, Icons.collections, () {
          CommonUtils.isLogin().then((isLogin) {
            if (isLogin) {
              CommonUtils.push(context, CollectionPage());
            } else {
              Fluttertoast.showToast(msg: S.of(context).please_login_first);
              CommonUtils.pushIOS(context, LoginPage());
            }
          });
        }),
        _menuItem(S.of(context).about_us, Icons.people, () {
          CommonUtils.push(
              context,
              WebViewPage(
                title: S.of(context).about_us,
                url: "http://www.wanandroid.com/about",
              ));
        }),

        StoreBuilder<MainRedux>(
          builder: (context,store){
            _store = store;
            return Offstage(
              offstage: store.state.user == null,
              child: Container(
                margin: EdgeInsets.only(top: 20),
                width: 200,
                child: RaisedButton(
                  color: Colors.lightBlueAccent,
                  onPressed: (){
                    CommonUtils.showCommitOptionDialog(
                        context, S.of(context).prompt,
                        S.of(context).logout_prompt, [S.of(context).ok,S.of(context).cancel],
                        (index){
                          if(index ==0){
                            _logout(context);
                          }
                        },bgColorList: [Colors.black26,Colors.green]);
                  },
                    child: Text(S.of(context).logout, style: TextStyle(color: Colors.white)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _logout(BuildContext context){
    DioManager.singleton.get("user/logout/json").then((result) {
      if (result != null) {
        Fluttertoast.showToast(msg: S.of(context).logout_success);
        SpManager.singleton.save(Const.ID, -1);
        SpManager.singleton.save(Const.USERNAME, "");
        _store.dispatch(UpdateUserAction(null));
        Navigator.pop(context);
      }
    });
  }

  Widget _menuItem(String text, IconData icon, Function() tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.black45,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                text,
                style: TextStyle(
                    color: ColorConst.color_333,
                    fontSize: TextSizeConst.smallTextSize),
              ),
            )
          ],
        ),
      ),
    );
  }


}

//CustomClipper 裁切路径

class ArcClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 30);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, size.height - 30);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }

}






















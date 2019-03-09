import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux/main_redux.dart';
import 'generated/i18n.dart';
import 'flash_page.dart';
import 'main_page.dart';
import 'utils/color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{

  final store = Store<MainRedux>(appReducer,initialState:MainRedux(user: null));

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }

}

import 'package:flutter/material.dart';

typedef SuccessWidget = Widget Function(AsyncSnapshot snapshot);

class AsyncSnapshotWidget extends StatelessWidget{

  AsyncSnapshot snapshot;

  SuccessWidget successWidget;

  AsyncSnapshotWidget({this.snapshot,@required this.successWidget});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _paresSnap();
  }

  Widget _paresSnap(){
    switch(snapshot.connectionState){
      case ConnectionState.none:
        return Center(child: Text("准备加载中..."),);
      case ConnectionState.active:
        print('active');
        return Center(
          child: CircularProgressIndicator(),
        );
      case ConnectionState.waiting:
        print('waiting');
        return Center(
          child: CircularProgressIndicator(),
        );
      case ConnectionState.done:
        print('done');
        return successWidget(snapshot);
      default:
        return null;
    }
  }

}
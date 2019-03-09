import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../generated/i18n.dart';
import '../../model/article.dart';
import '../../model/base_list_data.dart';
import '../../net/dio_manager.dart';
import '../../widget/collection_article_widget.dart';
import '../../widget/page_widget.dart';
import '../../widget/title_bar.dart';

class CollectionPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new CollectionPageState();
  }

}

class CollectionPageState extends State<CollectionPage> {

  RefreshController _refreshController;
  PageStateController _pageStateController;
  List<Article> articles = List();
  int pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshController = RefreshController();
    _pageStateController = PageStateController();
    getList(true);
  }

  void _onRefresh(bool up){
    if(up){
      pageIndex = 0;
      getList(true);
    }else{
      pageIndex++;
      getList(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: TitleBar(
        isShowBack: true,
        title: S.of(context).my_collection,
      ),
      body: PageWidget(
        controller: _pageStateController,
        reload: (){
          getList(true);
        },
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context,index){
              return CollectionArticleWidget(articles[index]);
            },
          ),
        ),
      ),
    );
  }



void getList(bool isRefresh){
    DioManager.singleton
        .get("lg/collect/list/${pageIndex}/json")
        .then((result){
          _refreshController.sendBack(isRefresh, RefreshStatus.idle);
          if(result != null){
            _pageStateController.changeState(PageState.LoadSuccess);
            var listdata = BaseListData.fromJson(result.data);
            print(listdata.toString());
            if(pageIndex ==0){
              articles.clear();
            }
            if(listdata.hasNoMore){
              _refreshController.sendBack(false, RefreshStatus.noMore);
            }
            setState(() {
              articles.addAll(Article.parseList(listdata.datas));
            });
          }else{
            _pageStateController.changeState(PageState.LoadFailed);
          }
    });
}







}
















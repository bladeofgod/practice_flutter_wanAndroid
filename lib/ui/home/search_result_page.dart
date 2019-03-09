import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/article.dart';
import '../../model/base_list_data.dart';
import '../../net/dio_manager.dart';
import '../../widget/article_widget.dart';
import '../../widget/page_widget.dart';
import '../../widget/titlebar.dart';


class SearchResultPage extends StatefulWidget{

  String keyWord = '';
  SearchResultPage(this.keyWord);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchResultPageState();
  }

}

class SearchResultPageState extends State<SearchResultPage> {

  int pageIndex= 0;
  List<Article> articles = List();
  RefreshController _refreshController;
  PageStateController _pageStateController;

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
        title: widget.keyWord,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(180),
        child: Icon(Icons.arrow_upward),
        onPressed: (){
          _refreshController.scrollTo(0);
        },
      ),
      body: PageWidget(
        reload: (){
          getList(true);
        },
        controller: _pageStateController,
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          child: ListView.builder(itemBuilder: (context,index){
            return ArticleWidget(articles[index]);
          },itemCount: articles.length,),
        ),
      ),
    );
  }


  void getList(bool isRefresh){
    DioManager.singleton
        .post("article/query/${pageIndex}/json", data: FormData.from({"k":widget.keyWord}))
        .then((result){
          _refreshController.sendBack(isRefresh, RefreshStatus.idle);
          if(result != null){
            _pageStateController.changeState(PageState.LoadSuccess);
            var listData = BaseListData.fromJson(result.data);

            if(pageIndex == 0){
              articles.clear();
            }
            if(listData.hasNoMore){
              _refreshController.sendBack(false, RefreshStatus.noMore);
            }
            setState(() {
              articles.addAll(Article.parseList(listData.datas));
            });
          }else{
            _pageStateController.changeState(PageState.LoadFailed);
          }
    });
  }
}





















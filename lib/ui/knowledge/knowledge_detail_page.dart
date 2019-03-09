import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/article.dart';
import '../../model/base_list_data.dart';
import '../../model/knowledge_system.dart';
import '../../net/dio_manager.dart';
import '../../utils/common.dart';
import '../../widget/article_widget.dart';
import '../../widget/page_widget.dart';
import '../../widget/titlebar.dart';


class KnowledgeDetailPage extends StatefulWidget{

  KnowledgeSystem knowledge;

  KnowledgeDetailPage({@required this.knowledge});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return KnowledgeDetailPageState();
  }

}

class KnowledgeDetailPageState extends State<KnowledgeDetailPage> with SingleTickerProviderStateMixin{

  TabController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: widget.knowledge.children.length, vsync: this,initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: TitleBar(
        isShowBack: true,
        title: widget.knowledge.name,
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            indicatorColor:Colors.green,
            controller: controller,
            isScrollable: true,
            tabs: parseTabs(),
          ),
          Expanded(
            flex: 1,
            child: TabBarView(children: parsePages(),
              controller: controller,),
          ),
        ],
      ),
    );
  }

  List<Widget> parseTabs(){
    List<Widget> widgets=List();
    var children = widget.knowledge.children;
    for(KnowledgeSystem item in children){
      var tab = Tab(
        text: item.name,
      );
      widgets.add(tab);
    }
    return widgets;
  }

  List<KnowledgeArticlePage> parsePages(){
    List<KnowledgeArticlePage> pages = List();
    var children = widget.knowledge.children;
    for(KnowledgeArticlePage item in children){
      var page = KnowledgeArticlePage(cid: item.cid,);
      pages.add(page);
    }

    return pages;
  }




}

class KnowledgeArticlePage extends StatefulWidget{

  int cid;
  KnowledgeArticlePage({@required this.cid});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new KnowledgeArticlePageState();
  }

}

class KnowledgeArticlePageState extends State<KnowledgeArticlePage> with AutomaticKeepAliveClientMixin {

  int pageIndex = 0;
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

  void _onRefresh(bool up) {
    if (up) {
      pageIndex = 0;
      getList(true);
    } else {
      pageIndex++;
      getList(false);
    }
  }

  void getList(bool isRefresh) {
    DioManager.singleton
        .get("article/list/${pageIndex}/json?cid=${widget.cid}")
        .then((result) {
      _refreshController.sendBack(isRefresh, RefreshStatus.idle);
      if (result != null) {
        _pageStateController.changeState(PageState.LoadSuccess);
        var listdata = BaseListData.fromJson(result.data);
        print(listdata.toString());
        if (pageIndex == 0) {
          articles.clear();
        }
        if (listdata.hasNoMore) {
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PageWidget(
      reload: (){
        getList(true);
      },
      controller: _pageStateController,
      child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return ArticleWidget(articles[index]);
              })),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
















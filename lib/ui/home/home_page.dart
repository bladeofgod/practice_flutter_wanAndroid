import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/article.dart';
import '../../model/base_list_data.dart';
import '../../model/base_data.dart';
import '../../model/banner.dart';
import '../../net/dio_manager.dart';
import '../../utils/color.dart';
import '../../utils/textsize.dart';
import '../../widget/article_widget.dart';
import '../../widget/page_widget.dart';


class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }

}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  List<BannerItem> banners = List();
  SwiperController _controlller = SwiperController();
  int pageIndex = 0;
  List<Article> articles = List();
  RefreshController _refreshController;
  PageStateController _pageStateController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controlller.autoplay = true;
    _refreshController = RefreshController();
    _pageStateController = PageStateController();
    getBanner();
    getList(true);


  }

  void getBanner() async{
    ResultData resultData = await DioManager.singleton.get("banner/json");
    setState(() {
      banners.clear();
      for(var item in resultData.data){
        banners.add(BannerItem.fromJson(item));
      }
    });
  }

  void _onRefresh(bool up){
    if(up){
      getBanner();
      pageIndex = 0;
      getList(true);
    }else{
      pageIndex ++ ;
      getList(false);
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: PageWidget(
        controller: _pageStateController,
        reload: (){
          getList(true);
        },
        child: SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          enablePullDown: true,
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: articles.length + 1,
            itemBuilder: (context,index){
              return index ==0 ?
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      width: MediaQuery.of(context).size.width,
                      height: 180,
                      child: banners.length != 0 ?
                          Swiper(
                            autoplayDelay: 5000,
                            controller: _controlller,
                            itemWidth: MediaQuery.of(context).size.width,
                            itemHeight: 180,
                            pagination: pagination(),
                            itemBuilder: (BuildContext context,int index){
                              return Image.network(
                                banners[index].imagePath,
                                fit: BoxFit.fill,
                              );
                            },
                            itemCount: banners.length,
                            viewportFraction: 0.8,
                            scale: 0.9,
                          ) : SizedBox(width: 0,height: 0,),
                    ) : ArticleWidget(articles[index - 1]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(180),
        child: Icon(Icons.arrow_upward),
        onPressed: (){
          _refreshController.scrollTo(0);
        },
      ),
    );
  }

  SwiperPagination pagination() => SwiperPagination(
    margin:EdgeInsets.all(0.0),
    builder:SwiperCustomPagination(builder: (BuildContext context,SwiperPluginConfig config){
      return Container(
        color: Color(0x599E9E9E),
        height: 40,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Row(
          children: <Widget>[
            Text(
              '${banners[config.activeIndex].title}',
              style: TextStyle(
                fontSize:TextSizeConst.smallTextSize,
                color:ColorConst.color_white
              ),
            ),
            Expanded(
              flex: 1,
              child: new Align(
                alignment: Alignment.centerRight,
                child: new DotSwiperPaginationBuilder(
                  color:Colors.black12,
                  activeColor:ColorConst.color_primary,
                  size:6.0,
                  activeSize:6.0
                ).build(context, config),
              ),
            ),
          ],
        ),
      );
    })
  );

  void getList(bool isRefresh){
    DioManager.singleton.get("article/list/${pageIndex}/json").then((result){
      _refreshController.sendBack(isRefresh, RefreshStatus.idle);
      if(result != null){
        _pageStateController.changeState(PageState.LoadSuccess);
        BaseListData listData = BaseListData.fromJson(result.data);
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}














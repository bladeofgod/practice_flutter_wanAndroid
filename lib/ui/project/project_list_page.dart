import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/base_list_data.dart';
import '../../model/project.dart';
import '../../net/dio_manager.dart';
import '../../ui/webview_page.dart';
import '../../utils/color.dart';
import '../../utils/common.dart';
import '../../utils/textsize.dart';
import '../../widget/page_widget.dart';


class ProjectListPage extends StatefulWidget{
  int cid = 0;

  ProjectListPage({@required this.cid});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProjectListPageState();
  }

}

class ProjectListPageState extends State<ProjectListPage> with AutomaticKeepAliveClientMixin {

  int pageIndex = 1;
  RefreshController _refreshController;
  PageStateController _pageStateController;
  List<Project> projects = List();

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _pageStateController = PageStateController();
    getList(true);
  }

  void _onRefresh(bool up) {
    if (up) {
      pageIndex = 1;
      getList(true);
    } else {
      pageIndex++;
      getList(false);
    }
  }

  void getList(bool isRefresh){
    DioManager.singleton
        .get("project/list/${pageIndex}/json?cid=${widget.cid}")
        .then((result){
          _refreshController.sendBack(isRefresh, RefreshStatus.idle);
          if(result != null){
            _pageStateController.changeState(PageState.LoadSuccess);
            var baseListData = BaseListData.fromJson(result.data);
            if(pageIndex == 1){
              projects.clear();
            }
            if(baseListData.hasNoMore){
              _refreshController.sendBack(false, RefreshStatus.noMore);
            }
            setState(() {
              projects.addAll(Project.parseList(baseListData.datas));
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
      reload: () {
        getList(true);
      },
      controller: _pageStateController,
      child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return _buildItem(projects[index]);
              })),
    );
  }

  Widget _buildItem(Project project){
    return GestureDetector(
      onTap: (){
        CommonUtils.push(context, WebViewPage(title: project.title,url: project.link,));
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              CachedNetworkImage(
                fit: BoxFit.fill,
                width: 100,
                height: 200,
                imageUrl: project.envelopePic,
                placeholder: ImageIcon(AssetImage("assets/logo.png"),size: 100,),
                errorWidget: Icon(Icons.info_outline),
              ),

              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(
                    left:10
                  ),
                  height: 200,
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.android,color: Colors.green,),
                          Expanded(
                            flex: 1,
                            child: Padding(padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "${project.title}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: ColorConst.color_333,
                                  fontSize: TextSizeConst.middleTextSize),
                            ),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                project.author,
                                maxLines: 1,
                                style: TextStyle(color: ColorConst.color_555),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              project.niceDate,
                              style: TextStyle(color: ColorConst.color_555,fontSize: TextSizeConst.minTextSize),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            project.desc,
                            maxLines: 6,
                            style: TextStyle(color: ColorConst.color_555),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}



















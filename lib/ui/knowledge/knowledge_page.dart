import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/knowledge_system.dart';
import '../../net/dio_manager.dart';
import '../../ui/knowledge/knowledge_detail_page.dart';
import '../../utils/color.dart';
import '../../utils/common.dart';
import '../../utils/textsize.dart';
import '../../widget/page_widget.dart';

class KnowledgePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KnowledgePageState();
  }
}

class _KnowledgePageState extends State<KnowledgePage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController;
  List datas = List<KnowledgeSystem>();
  PageStateController _pageStateController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _pageStateController=PageStateController();
    getList();
  }

  void _onRefresh(bool up) {
    if (up) {
      getList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      reload: (){
        getList();
      },
      controller: _pageStateController,
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: _onRefresh,
        child: ListView.builder(
            itemCount: datas.length,
            itemBuilder: (context, index) {
              var data = datas[index];
              return _buildItem(data);
            }),
      ),
    );
  }

  void getList() {
    DioManager.singleton.get("tree/json").then((result) {
      _refreshController.sendBack(true, RefreshStatus.idle);
      if (result != null) {
        _pageStateController.changeState(PageState.LoadSuccess);
        setState(() {
          datas.clear();
          List<KnowledgeSystem> knowledges =
          KnowledgeSystem.parseList(result.data);
          datas.addAll(knowledges);
        });
      }else{
        _pageStateController.changeState(PageState.LoadFailed);
      }
    });
  }

  Widget _buildItem(KnowledgeSystem item) {
    return GestureDetector(
      onTap: () {
        CommonUtils.push(
            context,
            KnowledgeDetailPage(
              knowledge: item,
            ));
      },
      child: Card(
        margin: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.name,
                        style: TextStyle(
                            fontSize: TextSizeConst.middleTextSize,
                            color: ColorConst.color_333),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          _parseDetail(item.children),
                          style: TextStyle(
                              fontSize: TextSizeConst.smallTextSize,
                              color: ColorConst.color_555),
                        ),
                      ),
                    ],
                  )),
              Icon(
                Icons.keyboard_arrow_right,
                color: ColorConst.color_555,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  String _parseDetail(List<KnowledgeSystem> children) {
    StringBuffer sb = StringBuffer();
    for (var item in children) {
      sb.write(item.name + "   ");
    }
    return sb.toString();
  }
}
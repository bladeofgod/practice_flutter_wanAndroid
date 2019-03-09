import 'package:flutter/material.dart';
import '../../generated/i18n.dart';
import '../../model/base_data.dart';
import '../../model/project_sort.dart';
import '../../net/dio_manager.dart';
import '../../ui/project/project_list_page.dart';
import '../../utils/color.dart';
import '../../widget/async_snapshot_widget.dart';
import '../../widget/load_fail_widget.dart';

class ProjectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ProjectPageState();
  }
}

class ProjectPageState extends State<ProjectPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  TabController _controller;
  List<ProjectSort> sorts = List();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      builder: _buildFuture,
      future: getSorts(),
    );
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
    return AsyncSnapshotWidget(
      snapshot: snapshot,
      successWidget: (snapshot) {
        ResultData result = snapshot.data;

        if (result != null) {
          List<ProjectSort> list = ProjectSort.parseList(result.data);
          sorts.clear();
          sorts.addAll(list);
          if (_controller == null) {
            _controller = TabController(
                length: sorts.length, vsync: this, initialIndex: 0);
          }
          return Column(
            children: <Widget>[
              TabBar(
                indicatorColor: Colors.green,
                controller: _controller,
                isScrollable: true,
                tabs: _parseTabs(),
              ),
              Expanded(
                flex: 1,
                child: TabBarView(
                  children: _parsePages(),
                  controller: _controller,
                ),
              ),
            ],
          );
        } else {
          return LoadFailWidget(
            onTap: () {
              setState(() {});
            },
          );
        }
      },
    );
  }

  List<Widget> _parseTabs() {
    List<Widget> widgets = List();
    for (ProjectSort item in sorts) {
      var tab = Tab(
        text: item.name,
      );
      widgets.add(tab);
    }
    return widgets;
  }

  Future getSorts() async{
    return DioManager.singleton.get("project/tree/json");
  }

  _parsePages(){
    List<ProjectListPage> pages = List();
    for (ProjectSort item in sorts) {
      var page = ProjectListPage(cid: item.id);
      pages.add(page);
    }
    return pages;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

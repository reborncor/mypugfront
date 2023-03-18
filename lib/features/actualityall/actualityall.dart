import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/pug/pugitem.dart';
import 'package:mypug/features/search/search.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/models/pugmodel.dart';
import 'package:mypug/response/actualityresponse.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'api.dart';

class ActualityAll extends StatefulWidget {
  final routeName = '/actualityall';

  const ActualityAll({Key? key}) : super(key: key);

  @override
  ActualityAllState createState() => ActualityAllState();
}

class ActualityAllState extends State<ActualityAll> {
  List<PugDetailModel> details = [];
  List<PugModel> list = [];
  late ActualityResponse _response;
  late String _username;
  late ScrollController scrollController =
      ScrollController(initialScrollOffset: 150);

  late int startInd = 0;
  late ThemeModel notifier;
  final RefreshController _refreshController = RefreshController();
  StreamController streamController = StreamController();
  bool scrollPagePhysique = false;
  late AppBar appBar;

  @override
  void initState() {
    fetchData();
    scrollController.addListener(scrollListener);
    super.initState();
  }

  fetchData() async {
    _username = await getCurrentUsername();
    _response = await getActualityPageable(startInd, 0);
    list = _response.pugs;
    streamController.add("event");
    streamController.done;
    socketService.initialise(_username);
  }

  fetchOldActuality() async {
    startInd += 5;
    _response = await getActualityPageable(startInd, 0);
    list.addAll(_response.pugs);
    streamController.add("event");
  }

  setScrollPhysique(bool value) {
    scrollPagePhysique = value;

    setState(() {});
  }

  scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      fetchOldActuality();
    }
    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {}
  }

  Future<void> refreshData() async {
    startInd = 0;
    list.clear();
    _response = await getActualityPageable(startInd, 0);
    list = _response.pugs;
    streamController.add("event");
    _refreshController.refreshCompleted();
    scrollController.animateTo(151,
        duration: const Duration(milliseconds: 700), curve: Curves.ease);
    scrollPagePhysique = false;
    setState(() {});
  }

  Widget pugItem(PugModel model) {
    return PugItem(model: model, currentUsername: _username);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
            appBar: AppBar(
              title: const Text("Actualité"),
              automaticallyImplyLeading: false,
              backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
              actions: [
                IconButton(
                    onPressed: () {
                      navigateWithName(context, const Search().routeName);
                    },
                    icon: const Icon(Icons.search)),
              ],
            ),
            body: Container(
              child: newContent(),
              decoration: BoxCircular(notifier),
            ));
      },
    );
  }

  Widget newContent() {
    String pathImage = notifier.isDark
        ? "asset/images/logo-header-dark.png"
        : "asset/images/logo-header-light.png";

    return StreamBuilder(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: APPCOLOR,
          ));
        }

        if (snapshot.hasData) {
          return SmartRefresher(
              controller: _refreshController,
              onRefresh: refreshData,
              child: CustomScrollView(controller: scrollController, slivers: [
                SliverAppBar(
                  expandedHeight: 150,
                  automaticallyImplyLeading: false,
                  backgroundColor:
                      notifier.isDark ? Colors.black : Colors.transparent,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.asset(
                      pathImage,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate([
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      scrollDirection: Axis.vertical,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return pugItem(list[index]);
                      })
                ]))
              ]));
        } else {
          return const Center(
            child: Text("Aucune publication"),
          );
        }
      },
    );
  }
}

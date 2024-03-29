import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../API/api_provider.dart';
import '../../Models/sections.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../../Widgets/category_specific_appbar.dart';
import '../HomeScreen/Widgets/dynamic_list_item.dart';
import '../HomeScreen/Widgets/ott_item.dart';

class LanguageSelectedPage extends StatefulWidget {
  const LanguageSelectedPage({super.key, required this.language});

  final String language;

  @override
  State<LanguageSelectedPage> createState() => _LanguageSelectedPageState();
}

class _LanguageSelectedPageState extends State<LanguageSelectedPage> {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  int page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_refreshController.position?.atEdge ?? false) {
        bool isTop = _refreshController.position?.pixels == 0;
        if (isTop) {
          _refreshController.requestRefresh();
        } else {
          // print('At the bottom');
          _refreshController.requestLoading();
        }
      }
    });
  }

  void _onRefresh() async {
    setState(() {
      page = 1;
    });
    // monitor network fetch
    fetchVideos(context);
    // if failed,use refreshFailed()
  }

  void _onLoading() async {
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length+1).toString());
    // if(mounted)
    //   setState(() {
    //
    //   });
    setState(() {
      page++;
    });
    fetchVideos(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(7.h),
          child: CategorySpecificAppbar(
              searchTerm: widget.language.split(",")[1])),
      body: FutureBuilder<List<Sections>>(
        builder: (context, _) {
          // return Center(
          //   child: Text(
          //     "No Data Available ${_.hasData} ${(_.data??[]).length>=0}",
          //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
          //       color: Colors.white,
          //     ),
          //   ),
          // );
          if (_.hasData && ((_.data ?? []).isNotEmpty)) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              color: Constants.backgroundColor,
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: const WaterDropHeader(),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus? mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = const Text("pull up load");
                    } else if (mode == LoadStatus.loading) {
                      body = const CupertinoActivityIndicator();
                    } else if (mode == LoadStatus.failed) {
                      body = const Text("Load Failed!Click retry!");
                    } else if (mode == LoadStatus.canLoading) {
                      body = const Text("release to load more");
                    } else {
                      body = const Text("No more Data");
                    }
                    return SizedBox(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: Consumer<Repository>(builder: (context, data, _) {
                  return SizedBox(
                    height: 100.h,
                    width: double.infinity,
                    child: Consumer<Repository>(builder: (context, data, _) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var item = data.languageSections[index];
                          return DynamicListItem(
                            text: item.title ?? "",
                            list: item.videos ?? [],
                            onTap: () {
                              Navigation.instance.navigate(Routes.moreScreen,
                                  args: item.title ?? "");
                            },
                          );
                        },
                        itemCount: data.languageSections.length,
                      );
                    }),
                  );
                }),
              ),
            );
          }
          if (_.hasError || (_.hasData&&(_.data ?? []).isEmpty)) {
            return Center(
              child: Text(
                "No Videos Available",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
              ),
            );
          }
          return const ShimmerLanguageScreen();
        },
        future: fetchVideos(context),
      ),
    );
  }

  Future<List<Sections>> fetchVideos(context) async {
    // Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance
        .getSections("language", "$page", widget.language.split(",")[0]);
    if (response.status ?? false) {
      // Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false)
          .addLanguageSections(response.sections ?? []);
      _refreshController.refreshCompleted();
      return response.sections ?? [];
    } else {
      // Navigation.instance.goBack();
      _refreshController.refreshCompleted();
      return List<Sections>.empty(growable: true);
      // showError(response.message ?? "Something went wrong");
    }
  }
}

class ShimmerLanguageScreen extends StatelessWidget {
  const ShimmerLanguageScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5.w,
        vertical: 2.h,
      ),
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.white70,
              child: Container(
                color: Colors.white30,
                width: 20.w,
                height: 2.h,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            SizedBox(
              width: double.infinity,
              height: 25.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.white70,
                    child: Container(
                      height: 20.h,
                      width: 40.w,
                      color: Colors.white30,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 2.h,
                  );
                },
                itemCount: 4,
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.white70,
              child: Container(
                color: Colors.white30,
                width: 20.w,
                height: 2.h,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            SizedBox(
              width: double.infinity,
              height: 25.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.white70,
                    child: Container(
                      height: 20.h,
                      width: 40.w,
                      color: Colors.white30,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 2.h,
                  );
                },
                itemCount: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



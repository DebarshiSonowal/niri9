import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../API/api_provider.dart';
import '../../Constants/common_functions.dart';
import '../../Constants/constants.dart';
import '../../Models/video.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../HomeScreen/Widgets/ott_item.dart';

class CategorySpecificScreen extends StatefulWidget {
  const CategorySpecificScreen({super.key, required this.searchTerm});

  final String searchTerm;

  @override
  State<CategorySpecificScreen> createState() => _CategorySpecificScreenState();
}

class _CategorySpecificScreenState extends State<CategorySpecificScreen> {
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
          child: CategorySpecificAppbar(searchTerm: widget.searchTerm)),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.backgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
        ),
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
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: FutureBuilder<List<Video>>(
              future: fetchVideos(context),
              builder: (context, _) {
                if (_.hasData) {
                  return SizedBox(
                    height: 100.h,
                    width: double.infinity,
                    child: Consumer<Repository>(builder: (context, data, _) {
                      return SingleChildScrollView(
                        child: GridView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: data.specificVideos.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 1.5.w,
                            mainAxisSpacing: 1.h,
                            childAspectRatio: 6.5 / 8.5,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            var item = data.specificVideos[index];
                            return OttItem(item: item, onTap: () {
                              if(Storage.instance.isLoggedIn){
                                Navigation.instance.navigate(Routes.watchScreen,args: item.id);
                              }else{
                                CommonFunctions().showLoginDialog(context);
                                // Navigation.instance.navigate(Routes.watchScreen,args: item.id);
                              }
                            });
                          },
                        ),
                      );
                    }),
                  );
                }
                if (_.hasError) {
                  return Center(
                    child: Text(
                      "Not Available",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  );
                }
                return const GridViewShimmering();
              }),
        ),
      ),
    );
  }

  Future<List<Video>> fetchVideos(context) async {
    // Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance
        .getVideos(page, null, widget.searchTerm, null, null, null);
    if (response.success ?? false) {
      // Navigation.instance.goBack();
      _refreshController.refreshCompleted();
      Provider.of<Repository>(context, listen: false)
          .setSearchVideos(response.videos);
      return response.videos ?? List<Video>.empty();
    } else {
      // Navigation.instance.goBack();
      _refreshController.refreshCompleted();
      return List<Video>.empty();
      // showError(response.message ?? "Something went wrong");
    }
  }
}

class GridViewShimmering extends StatelessWidget {
  const GridViewShimmering({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5.w,
        mainAxisSpacing: 1.h,
        childAspectRatio: 6.5 / 8.5,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.white70,
          child: Container(
            height: 20.h,
            width: 20.w,
            color: Colors.white30,
          ),
        );
      },
    );
  }
}

class CategorySpecificAppbar extends StatelessWidget {
  const CategorySpecificAppbar({
    super.key,
    required this.searchTerm,
  });

  final String searchTerm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 5.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 3.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigation.instance.goBack();
                  },
                  child: Icon(
                    Icons.arrow_back_ios_sharp,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
                // SizedBox(
                //   width: 5.w,
                // ),
                Text(
                  searchTerm.capitalize(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 15.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                ),
                Container()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

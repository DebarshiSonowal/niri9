import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizer/sizer.dart';

import '../../API/api_provider.dart';
import '../../Constants/common_functions.dart';
import '../../Constants/constants.dart';
import '../../Models/video.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../../Widgets/category_specific_appbar.dart';
import '../../Widgets/grid_view_shimmering.dart';
import '../HomeScreen/Widgets/ott_item.dart';

class CategorySpecificScreen extends StatefulWidget {
  const CategorySpecificScreen({super.key, required this.searchTerm});

  final String searchTerm;

  @override
  State<CategorySpecificScreen> createState() => _CategorySpecificScreenState();
}

class _CategorySpecificScreenState extends State<CategorySpecificScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  int page = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Repository>(context, listen: false).clearSpecificVideos();
    });
  }

  void _onRefresh() async {
    setState(() {
      page = 1;
    });
    fetchVideos(context);
  }

  void _onLoading() async {
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
          vertical: 1.h,
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
          child: Consumer<Repository>(builder: (context, data, _) {
            debugPrint(
                "Consumer rebuild - specificVideos count: ${data.specificVideos.length}, loading: ${data.loading}");

            if (data.loading && data.specificVideos.isEmpty) {
              return const GridViewShimmering();
            }

            if (data.specificVideos.isNotEmpty) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: data.specificVideos.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1.5.w,
                  mainAxisSpacing: 1.h,
                  childAspectRatio: 6.5 / 8.5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  var item = data.specificVideos[index];
                  return OttItem(
                      item: item,
                      onTap: () {
                        debugPrint(
                            "Clicked video: ${item.title}, ID: ${item.id}, isLoggedIn: ${Storage.instance.isLoggedIn}");
                        if (Storage.instance.isLoggedIn) {
                          Navigation.instance
                              .navigate(Routes.watchScreen, args: item.id);
                        } else {
                          CommonFunctions().showLoginDialog(
                              Navigation.instance.navigatorKey.currentContext ??
                                  context);
                        }
                      });
                },
              );
            } else {
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
          }),
        ),
      ),
    );
  }

  Future<List<Video>> fetchVideos(context) async {
    debugPrint(
        "fetchVideos called with page: $page, searchTerm: ${widget.searchTerm}");

    final response = await ApiProvider.instance
        .getVideos(page, null, widget.searchTerm, null, null, null, null);

    debugPrint(
        "API response success: ${response.success}, message: ${response.message}");
    debugPrint("API response videos count: ${response.videos?.length ?? 0}");

    // Debug each video if any exist
    if (response.videos?.isNotEmpty == true) {
      for (int i = 0; i < (response.videos?.length ?? 0) && i < 3; i++) {
        final video = response.videos![i];
        debugPrint("Video $i: title='${video.title}', id=${video.id}");
      }
    }

    if (response.success ?? false) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (page == 1) {
        debugPrint("Setting ${response.videos?.length ?? 0} videos for page 1");
        Provider.of<Repository>(context, listen: false)
            .setSearchVideos(response.videos ?? []);
      } else {
        final currentVideos =
            Provider.of<Repository>(context, listen: false).specificVideos;
        final List<Video> newVideos = [
          ...currentVideos,
          ...(response.videos ?? [])
        ];
        debugPrint(
            "Appending videos: ${currentVideos.length} + ${response.videos?.length ?? 0} = ${newVideos.length}");
        Provider.of<Repository>(context, listen: false)
            .setSearchVideos(newVideos);
      }

      // Additional debug for repository state
      final repo = Provider.of<Repository>(context, listen: false);
      debugPrint(
          "Repository specificVideos count after update: ${repo.specificVideos.length}");

      return response.videos ?? List<Video>.empty();
    } else {
      debugPrint("API response failed: ${response.message}");
      _refreshController.refreshCompleted();
      _refreshController.loadFailed();
      return List<Video>.empty();
    }
  }
}





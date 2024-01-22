import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Models/video.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/assets.dart';
import '../../Constants/common_functions.dart';
import '../../Helper/storage.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../../Widgets/category_specific_appbar.dart';
import '../../Widgets/grid_view_shimmering.dart';
import '../CategorySpecific/category_specific_screen.dart';
import '../HomeScreen/Widgets/ott_item.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  Future<List<Video>>? _future;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: const CategorySpecificAppbar(searchTerm: "My List"),
      ),
      body: Container(
        // color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 3.w,
          vertical: 1.h,
        ),
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder<List<Video>>(
          future: _future,
          builder: (context, _) {
            debugPrint("sda ${_.data} ${_.hasData} ${(_.data??[]) != []}");
            if (_.hasData && (_.data??[]) != []) {
              return SizedBox(
                height: 100.h,
                width: double.infinity,
                child: Consumer<Repository>(builder: (context,Repository data, _) {
                  return data.wishList.length<=0?Center(
                    child: Text(
                      "No Data Available",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 15.sp,
                      ),
                    ),
                  ):SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: data.wishList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1.5.w,
                        mainAxisSpacing: 1.h,
                        childAspectRatio: 6.5 / 8.5,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var item = data.wishList[index];
                        return OttItem(
                          item: item,
                          onLongPressed: () {
                            showDeleteDialog(item.id);
                          },
                          onTap: () {
                            if (Storage.instance.isLoggedIn) {
                              Navigation.instance
                                  .navigate(Routes.watchScreen, args: item.id);
                            } else {
                              CommonFunctions().showLoginDialog(context);
                              // Navigation.instance.navigate(Routes.watchScreen,args: item.id);
                            }
                          },
                        );
                      },
                    ),
                  );
                }),
              );
            }
            if (_.hasError || _.data == []) {
              return Center(
                child: Text(
                  "Not Available",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                    fontSize: 15.sp,
                      ),
                ),
              );
            }
            return const GridViewShimmering();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _future = fetchDetails(context);
      });
    });
  }

  Future<List<Video>> fetchDetails(BuildContext context) async {
    final response = await ApiProvider.instance.getMyVideos();
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .setWishList(response.videos);
      debugPrint("Fetched ${response.videos.length}");
      return response.videos;
    } else {
      debugPrint("Fetched2 ${response.videos.length}");
      return List<Video>.empty(growable: true);
    }
  }

  void removeFromList(id) async {
    final response = await ApiProvider.instance.addMyVideos(id);
    if (response.success ?? false) {
      Fluttertoast.showToast(msg: response.message ?? "Added To My List");
      fetchDetails(context);
    } else {
      Fluttertoast.showToast(msg: response.message ?? "Something went wrong");
    }
  }

  void showDeleteDialog(id) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Remove from My List",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            content: SizedBox(
              width: 40.w,
              height: 4.h,
              child: Center(
                child: Text(
                  "Do You Want To Remove It From List?",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  removeFromList(id);
                  Navigator.pop(context);
                },
                child: Text(
                  "Delete",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ),
            ],
          );
        });
  }
}

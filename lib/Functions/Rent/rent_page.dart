import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/common_functions.dart';
import '../../Constants/constants.dart';
import '../../Helper/storage.dart';
import '../../Models/video.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../../Widgets/alert.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../CategorySpecific/category_specific_screen.dart';
import '../HomeScreen/Widgets/home_banner.dart';

// import '../Premium/Widgets/dynamic_premium_list_item.dart';
// import '../Premium/Widgets/dynamic_premium_other_list_item.dart';
import '../HomeScreen/Widgets/ott_item.dart';
import '../Trending/Widgets/dynamic_premium_list_item.dart';
import '../Trending/Widgets/dynamic_premium_other_list_item.dart';

class RentPage extends StatefulWidget {
  const RentPage({super.key});

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  final ScrollController _scrollController = ScrollController();
   int page=1;
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Container(
    //     height: double.infinity,
    //     width: double.infinity,
    //     color: Colors.white,
    //   ),
    //   bottomNavigationBar: const CustomBottomNavBar(),
    // );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rent",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
                // fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Container(
        color: Constants.primaryColor,
        height: 100.h,
        width: 100.w,
        padding: EdgeInsets.symmetric(
          vertical: 0.5.h,
          horizontal: 2.w,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const HomeBanner(),
              // SizedBox(
              //   height: 0.5.h,
              // ),
              // Consumer<Repository>(builder: (context, data, _) {
              //   return Flexible(
              //     child: ListView.builder(
              //       shrinkWrap: true,
              //       physics: const NeverScrollableScrollPhysics(),
              //       itemBuilder: (context, index) {
              //         var item = data.premiumList[index];
              //         return DynamicPremiumListItem(
              //           text: item.title ?? "",
              //           list: item.list ?? [],
              //           onTap: () {
              //             Navigation.instance
              //                 .navigate(Routes.moreScreen, args: 0);
              //           },
              //         );
              //       },
              //       itemCount: data.premiumList.length,
              //     ),
              //   );
              // }),
              // Consumer<Repository>(builder: (context, data, _) {
              //   return Flexible(
              //     child: ListView.builder(
              //       shrinkWrap: true,
              //       physics: const NeverScrollableScrollPhysics(),
              //       itemBuilder: (context, index) {
              //         var item = data.premiumOthersList[index];
              //         return DynamicPremiumOtherListItem(
              //           text: item.title ?? "",
              //           list: item.list ?? [],
              //           onTap: () {
              //             Navigation.instance
              //                 .navigate(Routes.moreScreen, args: 0);
              //           },
              //         );
              //       },
              //       itemCount: data.premiumOthersList.length,
              //     ),
              //   );
              // }),
              SizedBox(
                height: 100.h,
                child: FutureBuilder(
                    builder: (context, _) {
                      if (_.hasData && (_.data != [])) {
                        return Consumer<Repository>(
                            builder: (context, data, _) {
                          return GridView.builder(
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
                              return OttItem(
                                  item: item,
                                  onTap: () {
                                    if (Storage.instance.isLoggedIn) {
                                      Navigation.instance
                                          .navigate(Routes.watchScreen, args: item.id);
                                    } else {
                                      CommonFunctions().showLoginDialog(context);
                                    }
                                  });
                            },
                          );
                        });
                      }
                      if (_.hasData && (_.data == [])) {
                        return Container();
                      }
                      return const GridViewShimmering();
                    },
                    future: fetchDetails(page, "", null, null, null)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  fetchRentals(context) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getRental();
    if (response.success ?? false) {
      Navigation.instance.goBack();
      Provider.of<Repository>(context, listen: false)
          .addRental(response.videos);
    } else {
      Navigation.instance.goBack();
      showError(response.message ?? "Something went wrong");
    }
  }

  void showError(String msg) {
    AlertX.instance.showAlert(
        title: "Error",
        msg: msg,
        positiveButtonText: "Done",
        positiveButtonPressed: () {
          Navigation.instance.goBack();
        });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      // fetchData(context);
      Provider.of<Repository>(context,listen: false).updateIndex(3);
    });
    Future.delayed(Duration.zero, () => fetchDetails(1, "", null, null, null));
    _scrollController.addListener(() {
      debugPrint("reach the top1");
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() {
          debugPrint("reach the top");

        });
      }
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() {
          debugPrint("reach the bottom");
        });
      }
    });
  }

  Future<List<Video>> fetchDetails(int page_no, String sections,
      String? category, String? genres, String? term) async {
    final response = await ApiProvider.instance.getVideos(
      page_no,
      sections,
      category,
      genres,
      term,
      "rent",
    );
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .setSearchVideos(response.videos);
      return response.videos;
    } else {
      return List<Video>.empty();
    }
  }
}

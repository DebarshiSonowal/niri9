import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../Widgets/title_box.dart';
import 'Widgets/custom_app_bar.dart';
import 'Widgets/dynamic_list_section.dart';
import 'Widgets/home_banner.dart';
import 'Widgets/language_section.dart';
import 'Widgets/recently_viewed_section.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  bool isExpanded = true, isEnd = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      // fetchData(context);
      Provider.of<Repository>(context, listen: false).updateIndex(0);
      fetchRecentlyViewed(context,1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            isExpanded ? 15.h : 24.h,
          ),
          child: CustomAppbar(
            isExpanded: isExpanded,
            updateState: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            color: Constants.primaryColor,
            height: 100.h,
            width: 100.w,
            padding: EdgeInsets.symmetric(
              vertical: 0.5.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HomeBanner(),
                  TitleBox(
                    text: "Explore in your language",
                    onTap: () {},
                    isEnd: false,
                  ),
                  LanguageSection(
                    scrollController: _scrollController,
                    onScroll: (UserScrollNotification notification) {
                      // final ScrollDirection direction = notification.direction;
                      // final ScrollMetrics metrics = notification.metrics;
                      //
                      // if (direction == ScrollDirection.forward &&
                      //     metrics.pixels > 0) {
                      //   // Slight swipe to the right
                      //   setState(() {
                      //     isEnd = false;
                      //   });
                      // } else if (direction == ScrollDirection.reverse &&
                      //     metrics.pixels < metrics.maxScrollExtent) {
                      //   // Slight swipe to the left
                      //
                      //   setState(() {
                      //     isEnd = true;
                      //   });
                      // }
                    },
                  ),
                  const RecentlyViewedSection(),
                  const DynamicListSectionHome(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }

  void fetchData(BuildContext context) async {
    // Navigation.instance.navigate(Routes.loadingScreen);

    if (!context.mounted) return;
    // await fetchLanguages(context);

    await fetchTypes(context);
    if (!context.mounted) return;
    await fetchRecentlyViewed(context,1);
    // Navigation.instance.goBack();
  }

  Future<void> fetchTypes(BuildContext context) async {
    final response = await ApiProvider.instance.getTypes();
    if (response.success ?? false) {
      if (!context.mounted) return;
      Provider.of<Repository>(context, listen: false).addTypes(response.types);
    } else {}
  }

// Future<void> fetchPrivacy(BuildContext context) async {
//   final response = await ApiProvider.instance.getPrivacyPolicy();
//   if (response.success ?? false) {
//     // if (!context.mounted) return;
//     Provider.of<Repository>(context, listen: false)
//         .updatePrivacy(response.result!);
//   } else {}
// }

// Future<void> fetchRefund(BuildContext context) async {
//   final response = await ApiProvider.instance.getRefundPolicy();
//   if (response.success ?? false) {
//     // if (!context.mounted) return;
//     Provider.of<Repository>(context, listen: false)
//         .updateRefund(response.result!);
//   } else {}
// }

// Future<void> fetchTerms(BuildContext context) async {
//   final response = await ApiProvider.instance.getRefundPolicy();
//   if (response.success ?? false) {
//     // if (!context.mounted) return;
//     Provider.of<Repository>(context, listen: false)
//         .updateRefund(response.result!);
//   } else {}
// }
  Future<void> fetchRecentlyViewed(BuildContext context,int page_no) async {
    final response = await ApiProvider.instance.getRecentlyVideos(page_no);
    if (response.success ?? false) {
      if (!context.mounted) return;
      Provider.of<Repository>(context, listen: false)
          .setRecentlyViewedVideos(response.videos);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../Widgets/title_box.dart';
import 'Widgets/custom_app_bar.dart';
import 'Widgets/dynamic_list_item.dart';
import 'Widgets/home_banner.dart';
import 'Widgets/language_section.dart';
import 'Widgets/ott_item.dart';

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
      fetchData(context);
    });
    _scrollController.addListener(() {
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          isEnd != false) {
        setState(() {
          debugPrint("reach the top");
          isEnd = false;
        });
      }
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          isEnd == false) {
        setState(() {
          debugPrint("reach the bottom");
          isEnd = true;
        });
      }
    });
    // Provider.of<Repository>(context, listen: false).set
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onTap: () {

                  },
                  isEnd: isEnd,
                ),
                LanguageSection(
                  scrollController: _scrollController,
                ),
                Consumer<Repository>(builder: (context, data, _) {
                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var item = data.homeSections[index];
                        return item.videos.isNotEmpty
                            ? DynamicListItem(
                                text: item.title ?? "",
                                list: item.videos ?? [],
                                onTap: () {
                                  Navigation.instance.navigate(
                                      Routes.moreScreen,
                                      args: item.slug ?? "");
                                },
                              )
                            : Container();
                      },
                      itemCount: data.homeSections.length,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  void fetchData(BuildContext context) async {
    Navigation.instance.navigate(Routes.loadingScreen);

    if (!context.mounted) return;
    await fetchLanguages(context);
    if (!context.mounted) return;
    await fetchTypes(context);
    Navigation.instance.goBack();
  }

  Future<void> fetchLanguages(BuildContext context) async {
    final response = await ApiProvider.instance.getLanguages();
    if (response.status ?? false) {
      // if (!context.mounted) return;
      Provider.of<Repository>(context, listen: false)
          .addLanguages(response.languages);
    } else {}
  }

  Future<void> fetchTypes(BuildContext context) async {
    final response = await ApiProvider.instance.getTypes();
    if (response.success ?? false) {
      // if (!context.mounted) return;
      Provider.of<Repository>(context, listen: false).addTypes(response.types);
    } else {}
  }

  Future<void> fetchPrivacy(BuildContext context) async {
    final response = await ApiProvider.instance.getPrivacyPolicy();
    if (response.success ?? false) {
      // if (!context.mounted) return;
      Provider.of<Repository>(context, listen: false)
          .updatePrivacy(response.result!);
    } else {}
  }

  Future<void> fetchRefund(BuildContext context) async {
    final response = await ApiProvider.instance.getRefundPolicy();
    if (response.success ?? false) {
      // if (!context.mounted) return;
      Provider.of<Repository>(context, listen: false)
          .updateRefund(response.result!);
    } else {}
  }

  Future<void> fetchTerms(BuildContext context) async {
    final response = await ApiProvider.instance.getRefundPolicy();
    if (response.success ?? false) {
      // if (!context.mounted) return;
      Provider.of<Repository>(context, listen: false)
          .updateRefund(response.result!);
    } else {}
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Models/ott.dart';
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
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          isExpanded?15.h:24.h,
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
      body: Container(
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
              ),
              const LanguageSection(),
              Consumer<Repository>(builder: (context, data, _) {
                return Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = data.dynamicList[index];
                      return DynamicListItem(
                        text: item.title ?? "",
                        list: item.list ?? [],
                        onTap: () {
                          Navigation.instance
                              .navigate(Routes.moreScreen, args: 0);
                        },
                      );
                    },
                    itemCount: data.dynamicList.length,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

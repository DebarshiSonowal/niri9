import 'package:flutter/material.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/constants.dart';
import '../../Navigation/Navigate.dart';
import '../../Router/routes.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../HomeScreen/Widgets/dynamic_list_item.dart';
import '../HomeScreen/Widgets/home_banner.dart';
import 'Widgets/dynamic_premium_list_item.dart';
import 'Widgets/dynamic_premium_other_list_item.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Premium",
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
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HomeBanner(),
              SizedBox(
                height: 0.5.h,
              ),
              Consumer<Repository>(builder: (context, data, _) {
                return Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = data.premiumList[index];
                      return DynamicPremiumListItem(
                        text: item.title ?? "",
                        list: item.list ?? [],
                        onTap: () {
                          Navigation.instance
                              .navigate(Routes.moreScreen, args: 0);
                        },
                      );
                    },
                    itemCount: data.premiumList.length,
                  ),
                );
              }),
              Consumer<Repository>(builder: (context, data, _) {
                return Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = data.premiumOthersList[index];
                      return DynamicPremiumOtherListItem(
                        text: item.title ?? "",
                        list: item.list ?? [],
                        onTap: () {
                          Navigation.instance
                              .navigate(Routes.moreScreen, args: 0);
                        },
                      );
                    },
                    itemCount: data.premiumOthersList.length,
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

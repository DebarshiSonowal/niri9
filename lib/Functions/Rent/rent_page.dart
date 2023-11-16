import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/constants.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../../Widgets/alert.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../HomeScreen/Widgets/home_banner.dart';
// import '../Premium/Widgets/dynamic_premium_list_item.dart';
// import '../Premium/Widgets/dynamic_premium_other_list_item.dart';
import '../Trending/Widgets/dynamic_premium_list_item.dart';
import '../Trending/Widgets/dynamic_premium_other_list_item.dart';

class RentPage extends StatefulWidget {
  const RentPage({super.key});

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {



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
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HomeBanner(),
              SizedBox(
                height: 0.5.h,
              ),
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
    Future.delayed(Duration.zero,()=>fetchRentals(context));
  }
}

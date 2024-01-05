import 'package:flutter/material.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Models/appbar_option.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/assets.dart';
import '../../../Constants/constants.dart';
import '../../../Repository/repository.dart';
import '../../../Router/routes.dart';
import '../../../Widgets/custom_appbar_item.dart';

class CustomAppbar extends StatelessWidget {
  CustomAppbar({required this.isExpanded, required this.updateState});

  final bool isExpanded;
  final Function updateState;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Constants.primaryColor,
      elevation: 5,
      child: Column(
        children: [
          SizedBox(
            height: 2.5.h,
          ),
          Row(
            children: [
              SizedBox(
                width: 4.w,
              ),
              Image.asset(
                Assets.logoTransparent,
                height: 7.h,
                width: 14.w,
                fit: BoxFit.cover,
              ),
              SizedBox(
                width: 2.w,
              ),
              const SubscriptionAlert(),
            ],
          ),
          Consumer<Repository>(
            builder: (context, data, _) {
              return FirstLineAppbar(
                  updateState: updateState, isExpanded: isExpanded, data: data);
            },
          ),
          !isExpanded
              ? Divider(
                  thickness: 0.03.h,
                  color: Colors.white,
                )
              : Container(),
          !isExpanded
              ? Row(
                  children: [
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      "More Options",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white54,
                            fontSize: 8.sp,
                          ),
                    ),
                  ],
                )
              : Container(),
          !isExpanded
              ? SizedBox(
                  height: 0.5.h,
                )
              : Container(),
          !isExpanded
              ? Consumer<Repository>(
                  builder: (context, data, _) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                      ),
                      width: double.infinity,
                      height: 6.h,
                      child: ListView.separated(
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          var item = data.appbarOptions.sublist(3)[index];
                          return CustomAppbarItem(
                            item: item,
                            index: index,
                            onTap: () {
                              Navigation.instance
                                  .navigate(Routes.subscriptionScreen);
                              if (index == 3) {
                                // Navigation.instance
                                //     .navigate(Routes.filmFestivalScreen);
                              } else if (index == 5) {}
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            width: 6.w,
                          );
                        },
                        itemCount: (data.appbarOptions.sublist(4).length),
                      ),
                    );
                  },
                )
              : Container(),
          !isExpanded
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12.w,
                      child: Divider(
                        thickness: 0.3.h,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

class SubscriptionAlert extends StatelessWidget {
  const SubscriptionAlert({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3.h,
      // margin: EdgeInsets.symmetric(
      //   horizontal: 2.w,
      //   vertical: 0.1.h,
      // ),
      child: Consumer<Repository>(builder: (context, data, _) {
        return (data.user?.has_subscription ?? false)
            ? Shimmer.fromColors(
                baseColor: const Color(0xffffed8c),
                highlightColor: const Color(0xffFFD700),
                child: GestureDetector(
                  onTap: () {
                    if (Storage.instance.isLoggedIn) {
                      Navigation.instance.navigate(Routes.subscriptionScreen);
                    } else {
                      Navigation.instance.navigate(Routes.loginScreen);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xffffed8c),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Subscribe",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xffffed8c),
                              fontSize: 8.sp,
                            ),
                      ),
                    ),
                  ),
                ),
              )
            : Container();
      }),
    );
  }
}

class FirstLineAppbar extends StatelessWidget {
  const FirstLineAppbar({
    super.key,
    required this.updateState,
    required this.isExpanded,
    required this.data,
  });

  final Repository data;
  final Function updateState;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 2.w,
      ),
      width: double.infinity,
      height: 6.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 76.w,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index != 0) {
                  var item = data.appbarOptions[index-1];
                  return CustomAppbarItem(
                    item: item,
                    index: index - 1,
                    onTap: () {
                      if (item.name?.toLowerCase() == "film festival" &&
                          (item.has_festival ?? false)) {
                        Navigation.instance.navigate(Routes.filmFestivalScreen);
                      } else {
                        Navigation.instance.navigate(
                            Routes.selectedCategoryScreen,
                            args: "${item.slug}");
                      }
                    },
                  );
                } else {
                  var item = AppBarOption(
                    name: data.categoryAll?.title ?? "",
                    slug: data.categoryAll?.slug ?? "",
                    image: data.categoryAll?.img ??
                        "https://picsum.photos/200/300",
                    sequence: 0,
                    has_festival: false,
                  );
                  return CustomAppbarItem(
                    item: item,
                    index: index,
                    onTap: () {
                      if (item.name?.toLowerCase() == "film festival" &&
                          (item.has_festival ?? false)) {
                        Navigation.instance.navigate(Routes.filmFestivalScreen);
                      } else {
                        Navigation.instance.navigate(
                            Routes.selectedCategoryScreen,
                            args: "${item.name}");
                      }
                    },
                  );
                }
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 4.w,
                );
              },
              itemCount: ((data.appbarOptions.length + 1) > 4
                  ? 4
                  : data.appbarOptions.length + 1),
            ),
          ),
          data.appbarOptions.length <= 4
              ? Container()
              : SizedBox(
                  width: 10.w,
                  child: GestureDetector(
                    onTap: () {
                      updateState();
                    },
                    child: SizedBox(
                      width: 15.w,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              !isExpanded ? Assets.lessImage : Assets.moreImage,
                              height: 12.sp,
                              width: 12.sp,
                              // color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

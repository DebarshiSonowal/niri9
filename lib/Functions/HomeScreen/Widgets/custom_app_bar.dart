import 'package:flutter/material.dart';
import 'package:niri9/Models/appbar_option.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:provider/provider.dart';
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
            height: 3.h,
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
            ],
          ),
          Consumer<Repository>(
            builder: (context, data, _) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                ),
                width: double.infinity,
                height: 6.h,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    var item = isExpanded
                        ? data.appbarOptions[index]
                        : data.appbarOptions2[index];
                    return CustomAppbarItem(
                      item: item,
                      index: index,
                      onTap: () {
                        if (index == 3) {
                          Navigation.instance
                              .navigate(Routes.filmFestivalScreen);
                        } else if (index == 5) {
                          updateState();
                        }
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      width: 6.w,
                    );
                  },
                  itemCount:
                      (isExpanded ? data.appbarOptions : data.appbarOptions2)
                          .length,
                ),
              );
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
              ? Consumer<Repository>(
                  builder: (context, data, _) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                      ),
                      width: double.infinity,
                      height: 6.h,
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          var item = data.appbarOptions3[index];
                          return CustomAppbarItem(
                            item: item,
                            index: index,
                            onTap: () {
                              if (index == 3) {
                                Navigation.instance
                                    .navigate(Routes.filmFestivalScreen);
                              } else if (index == 5) {}
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            width: 6.w,
                          );
                        },
                        itemCount: data.appbarOptions3.length,
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

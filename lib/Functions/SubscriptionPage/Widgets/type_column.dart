import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';

class TypeColumn extends StatelessWidget {
  const TypeColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 3.h,
          ),
          SizedBox(
            width: double.infinity,
            height: 3.h,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisAlignment:
              MainAxisAlignment.start,
              children: [
                Text(
                  "Movies, Sports, Originals",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    color: Constants.plansColor,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 3.h,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisAlignment:
              MainAxisAlignment.start,
              children: [
                Text(
                  "Watch on Tv",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    color: Constants.plansColor,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 3.h,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisAlignment:
              MainAxisAlignment.start,
              children: [
                Text(
                  "Ad free",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    color: Constants.plansColor,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 3.h,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisAlignment:
              MainAxisAlignment.start,
              children: [
                Text(
                  "Number of Screens",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    color: Constants.plansColor,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 3.h,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisAlignment:
              MainAxisAlignment.start,
              children: [
                Text(
                  "Video Quality",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    color: Constants.plansColor,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
          DottedLine(
            lineLength: double.infinity,
            dashColor: Colors.white70,
            lineThickness: 0.05.h,
          ),
          SizedBox(
            width: double.infinity,
            height: 5.h,
          ),
        ],
      ),
    );
  }
}
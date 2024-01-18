import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/assets.dart';
import '../../../Constants/constants.dart';
import '../../../Navigation/Navigate.dart';

class FilmFestivalAppbar extends StatelessWidget {
  const FilmFestivalAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 5.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 3.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigation.instance.goBack();
                  },
                  child: Icon(
                    Icons.arrow_back_ios_sharp,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
                // SizedBox(
                //   width: 5.w,
                // ),
                Row(
                  children: [
                    Text(
                      "NIRI 9 ",
                      style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 12.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      Assets.filmImage,
                      scale: 13,
                    ),
                    Text(
                      " FILM FESTIVAL",
                      style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 12.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container()
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Container(
                width: 37.w,
                decoration: BoxDecoration(
                  color: const Color(0xff0a5079),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.w,
                ),
                child: Column(
                  children: [
                    Text(
                      "REGISTER",
                      style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 13.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "To Submit Your Films",
                      style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white30,
                        fontSize: 6.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(),
              Container(
                width: 37.w,
                decoration: BoxDecoration(
                  color: const Color(0xffd49b03),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.w,
                ),
                child: Column(
                  children: [
                    Text(
                      "BUY TICKETS",
                      style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 13.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Attend Film Festival",
                      style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Color(0xff8e7b55),
                        fontSize: 6.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(),
            ],
          ),
          SizedBox(
            height: 1.5.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "NIRI 9 ",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 12.5.sp,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "INTERNATIONAL ",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xfff15355),
                  fontSize: 12.5.sp,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "FILM FESTIVAL 20",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 12.5.sp,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "23",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xfff15355),
                  fontSize: 12.5.sp,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Submit Your Entries Before 23rd March",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xfff15355),
                  fontSize: 7.sp,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
            ],
          ),
          SizedBox(
            height: 1.5.h,
          ),
        ],
      ),
    );
  }
}
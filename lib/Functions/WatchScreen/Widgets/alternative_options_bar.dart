import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class AlternativeOptionsBar extends StatelessWidget {
  const AlternativeOptionsBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white54,
            width: 0.03.h,
          ),
          bottom: BorderSide(
            color: Colors.white54,
            width: 0.03.h,
          ),
        ),
      ),
      height: 10.h,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: 1.h,
              ),
              color: const Color(0xff2a2829),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.white30,
                        child: Icon(
                          Icons.share,
                          color: Colors.white30,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(
                        height: 1.2.h,
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.white30,
                        child: Container(
                          height: 2.h,
                          width: 10.w,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.white30,
                        child: Icon(
                          Icons.playlist_add,
                          color: Colors.white30,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(
                        height: 1.2.h,
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.white30,
                        child: Container(
                          height: 2.h,
                          width: 10.w,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.white30,
                        child: Icon(
                          Icons.money,
                          color: Colors.white30,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(
                        height: 1.2.h,
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.white30,
                        child: Container(
                          height: 2.h,
                          width: 10.w,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.white30,
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white30,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(
                    height: 1.2.h,
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.white30,
                    child: Container(
                      height: 2.h,
                      width: 20.w,
                      color: Colors.white30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
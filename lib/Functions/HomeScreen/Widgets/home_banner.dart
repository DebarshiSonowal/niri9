
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({Key? key}) : super(key: key);

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return SizedBox(
        width: double.infinity,
        height: 25.h,
        child: CarouselSlider.builder(
          itemCount: data.bannerList.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            var item = data.bannerList[index];
            return Container(
              height: 25.h,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.asset(
                    item,
                    fit: BoxFit.fill,
                    height: 25.h,
                    width: double.infinity,
                  ),
                  Container(
                    height: 1.2.h,
                    // color: Colors.grey,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      bottom: 0.7.h,
                    ),
                    // child: Row(
                    //   children: [
                    //     SizedBox(
                    //       height: 4.h,
                    //       width: 10.h,
                    //       child: Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Icon(
                    //             Icons.add,
                    //             color: Colors.white,
                    //           ),
                    //           Text(
                    //             "My List",
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .bodySmall
                    //                 ?.copyWith(
                    //                   color: Colors.white,
                    //                 ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     ListView.separated(
                    //       scrollDirection: Axis.horizontal,
                    //       shrinkWrap: true,
                    //       itemBuilder: (context, index) {
                    //         return Container(
                    //           // height: 1.h,
                    //           width: 5.w,
                    //           decoration: BoxDecoration(
                    //             color: index == _current
                    //                 ? Colors.white
                    //                 : const Color(0xff464646),
                    //             borderRadius: BorderRadius.circular(1.h),
                    //           ),
                    //         );
                    //       },
                    //       separatorBuilder: (context, index) {
                    //         return SizedBox(
                    //           width: 3.w,
                    //         );
                    //       },
                    //       itemCount: data.bannerList.length,
                    //     ),
                    //   ],
                    // ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            autoPlay: true,
            enableInfiniteScroll: true,
            // enlargeCenterPage: true,
            aspectRatio: 10.5 / 9,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
      );
    });
  }
}
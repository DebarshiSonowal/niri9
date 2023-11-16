import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Functions/Trending/Widgets/trending_slider_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';
import '../../HomeScreen/Widgets/my_list_button.dart';
import '../../HomeScreen/Widgets/share_indicator.dart';
import '../../HomeScreen/Widgets/slider_indicator.dart';


class TrendingBanner extends StatefulWidget {
  const TrendingBanner({Key? key}) : super(key: key);

  @override
  State<TrendingBanner> createState() => _TrendingBannerState();
}

class _TrendingBannerState extends State<TrendingBanner> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return SizedBox(
        width: double.infinity,
        height: 25.h,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            data.trendingBanner.isNotEmpty?SizedBox(
              height: 25.h,
              width: double.infinity,
              child: CarouselSlider.builder(
                // itemCount: data.bannerList.length,
                itemCount: data.trendingBanner.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  var item = data.trendingBanner[index];
                  return SizedBox(
                    height: 23.h,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        CachedNetworkImage(
                          imageUrl: item.profilePic ?? "",
                          fit: BoxFit.fill,
                          height: 25.h,
                          width: double.infinity,
                        ),
                        Container(
                          height: 7.h,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                          ),
                          // color: Colors.grey,
                          width: double.infinity,

                          padding: EdgeInsets.only(
                            bottom: 0.7.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 30.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.h,
                                ),
                                child: Center(
                                  child: Text(
                                    "Play Now",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
            ):Container(),
            data.trendingBanner.isNotEmpty?Container(
              margin: EdgeInsets.only(
                bottom: 1.h,
              ),
              width: double.infinity,
              height: 5.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyListButton(
                    onTap: () {},
                  ),
                  SizedBox(
                    width: 3.w,
                  ),
                  TrendingSliderIndicator(current: _current),
                  SizedBox(
                    width: 3.w,
                  ),
                  ShareIndicator(
                    onTap: () {},
                  ),
                ],
              ),
            ):Container(),
          ],
        ),
      );
    });
  }
}







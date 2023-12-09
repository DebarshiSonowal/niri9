import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Models/banner.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';
import 'my_list_button.dart';
import 'share_indicator.dart';
import 'slider_indicator.dart';

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
        height: 40.h,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            data.homeBanner.isNotEmpty?SizedBox(
              height: 40.h,
              width: double.infinity,
              child: CarouselSlider.builder(
                // itemCount: data.bannerList.length,
                itemCount: data.homeBanner.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  var item = data.homeBanner[index];
                  return BannerImageItem(item: item);
                },
                options: CarouselOptions(
                  autoPlay: true,
                  enableInfiniteScroll: true,
                  // enlargeCenterPage: true,
                  aspectRatio: 10 / 9,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              ),
            ):Container(),
            data.homeBanner.isNotEmpty?Container(
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
                  SliderIndicator(current: _current),
                  SizedBox(
                    width: 3.w,
                  ),
                  ShareIndicator(
                    onTap: () {
                      Share.share('check out NIRI9 from ');
                    },
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

class BannerImageItem extends StatelessWidget {
  const BannerImageItem({
    super.key,
    required this.item,
  });

  final BannerResult item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CachedNetworkImage(
            imageUrl: item.posterPic ?? "",
            fit: BoxFit.fill,
            height: 40.h,
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
  }
}






